class User::AdsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!, except: [:new, :create, :send_message, :show]
  before_action :requires_user, except: [:new, :create, :send_message, :show]
  after_action :verify_authorized, except: [:new, :create, :send_message, :send_message]

  include ApplicationHelper

  def show
    @ad = Ad.includes(:location => :district).where(id: params['id']).first!
    authorize @ad

    # Redirection to the home page, if this ad has expired, expect if current user owns this ad.
    if @ad.expire_date < Date.today
      if @ad.user != current_user
        flash[:error] = t('ad.ad_has_expired')
        redirect_to root_path
      else
        @your_ad_has_expired = true
      end
    end

    get_map_settings_for_ad
  end

  def new
    @ad = Ad.new(is_published: false)
    authorize @ad
    get_map_settings_for_ad
  end

  def create
    @ad = Ad.new(ad_params)
    authorize @ad

    # we tie now the user to the ad (if it is an anonymous user, current_user is nil)
    @ad.user = current_user

    if @ad.save_with_or_without_captcha(current_user)
      flash[:new_ad] = @ad.title

      # Letting the user know when their ad will expire.
      if (max_number_days_publish.to_i > 0)
        flash[:ad_expire] = t('ad.ad_create_expire', day_number: max_number_days_publish, expire_date: @ad.expire_date)
      end

      redirect_to ad_path(@ad.id)

      # Sending email confirmation, about the creation of the ad.
      full_admin_url = "http://#{request.env['HTTP_HOST']}/user/manageads"
      # Reloading the now-created ad, with associated items.
      @ad = Ad.includes([:items, :categories]).where(id: @ad.id).first
      user_info = {}
      if current_user
        user_info = {email: current_user.email, name: current_user.first_name, is_anon: false}
      else
        user_info = {email: @ad.anon_email, name: @ad.anon_name, is_anon: true}
      end

      if is_on_heroku
        UserMailer.created_ad(user_info, @ad, full_admin_url).deliver
      else
        # Queueing email sending, when not on heroku.
        UserMailer.delay.created_ad(user_info, @ad, full_admin_url)
        super_admins = User.where(role: 2).pluck('email')
        # Sending email to super-admin to notify them that a new ad has been posted.
        UserMailer.delay.created_ad_notify_super_admins(user_info, @ad, super_admins)
      end

    else
      # Saving the ad failed.
      get_map_settings_for_ad
      render action: 'new'
    end
  end

  def edit
    @ad = Ad.includes(:location => :district).where(id: params[:id]).first!
    authorize @ad
    get_map_settings_for_ad
  end

  def update
    @ad = Ad.find(params[:id])
    authorize @ad

    # Performing the update.
    if @ad.update(ad_params)
      flash[:ad_updated] = @ad.title

      if !current_user.super_admin?
        # if a service was updated by someone who's not a super-admin,
        # send emails to super-admins.
        user_info = {email: current_user.email, name: current_user.first_name, is_anon: false}
        super_admins = User.where(role: 2).pluck('email')
        UserMailer.delay.updated_ad_notify_super_admins(user_info, @ad, super_admins)
      end

      redirect_to edit_user_ad_path(@ad.id)
    else
      # Saving the ad failed.
      flash[:error_ad] = @ad.title
      get_map_settings_for_ad
      render action: 'edit'
    end
  end

  def destroy
    @ad = Ad.find(params[:id])
    authorize @ad
    deleted_ad_title = @ad.title

    if @ad.destroy
      flash[:success] = t('ad.ad_is_deleted', deleted_ad_title: deleted_ad_title)
      redirect_to user_manageads_path
    else
      # Deleting the ad failed.
      flash[:error_delete_ad] = @ad.title
      get_map_settings_for_ad
      render action: 'edit'
    end
  end

  def ad_params
    params.require(:ad).permit(:title, :description, :is_username_used, :location_id, :is_giving, {category_ids: []}, :user_id,
                               :image, :image_cache, :remove_image, :anon_name, :anon_email, :captcha, :captcha_key, :funding_source, :benef_age_group, :is_parental_support, :is_published,
                               :ad_items_attributes => [:id, :item_id, :_destroy, :item_attributes => [:id, :name, :_destroy] ],
                               :location_attributes => [:id, :user_id, :name, :street_number, :address, :postal_code, :province, :city, :district_id, :loc_type, :latitude, :longitude, :phone_number, :website, :description, :facebook, :_destroy])
  end

  # This method is called when a user replies and sends a message to another user, who posted an ad.
  # It sends the reply to the user who published this ad.
  def send_message
    message = params[:message]
    @ad = Ad.find(params['id'])

    if current_user == nil && !simple_captcha_valid?
      flash.now[:error_message] = t('ad.captcha_not_valid')
      get_map_settings_for_ad
      render action: 'show'
    else
      if message && message.gsub(/\s+/, '') != ''
        if @ad.is_anonymous
          # Storing info for message to send to a anonymous publisher
          ad_info = {title: @ad.title, first_name: @ad.anon_name, email: @ad.anon_email}
        else
          # Storing info for message to send to a registered publisher
          ad_info = {title: @ad.title, first_name: @ad.user.first_name, email: @ad.user.email}
        end

        if current_user
          # The message sender is a registered user.
          sender_info = {full_name: "#{current_user.first_name} #{current_user.last_name}" , email: current_user.email}
        else
          # The message sender is an anonymous user.
          sender_info = {full_name: params['name'], email: params['email']}
        end

        if is_on_heroku
          UserMailer.send_message_for_ad(sender_info, message, ad_info).deliver
        else
          UserMailer.delay.send_message_for_ad(sender_info, message, ad_info)
        end
        flash[:success] = t('ad.success_sent')
      else
        flash[:error] = t('ad.error_empty_message')
      end

      redirect_to ad_path(params['id'])
    end
  end

  private

  # Initializes map related info (markers, clickable map...)
  def get_map_settings_for_ad
    if %w(show send_message).include?(action_name)
      getMapSettingsWithSeveralItems(@ad, HAS_CENTER_MARKER, NOT_CLICKABLE_MAP)
    elsif %w(create update).include?(action_name)
      getMapSettings(@ad.location, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    else
      getMapSettings(@ad.location, HAS_NOT_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    end
  end

end
