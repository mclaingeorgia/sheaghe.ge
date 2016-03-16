class Ad < ActiveRecord::Base
  has_many :ad_locations
  has_many :locations, through: :ad_locations
  has_many :ad_items
  has_many :items, through: :ad_items
  belongs_to :user
  has_many :ad_users
  has_many :favoriting_users, through: :ad_users, source: :user
  has_and_belongs_to_many :categories

  include ApplicationHelper
  after_initialize :default_values

  # Ad image
  mount_uploader :image, ImageUploader

  process_in_background :image if :image_storage == IMAGE_AMAZON_S3
  store_in_background :avatar if :image_storage == IMAGE_ON_SERVER

  accepts_nested_attributes_for :ad_locations, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :ad_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items
  accepts_nested_attributes_for :locations

  validates_presence_of :title, :description
  validates :is_giving, inclusion: [true, false]
  validates :is_username_used, inclusion: [true, false]
  validates :is_published, inclusion: [true, false]
  validate :has_items
  validate :has_locations
  validate :must_have_one_category
  validates_size_of :image, maximum: 5.megabytes

  # Fields to be translated
  translates :title, :description
  globalize_accessors :locales => [:en, :ka], :attributes => [:title]
  globalize_accessors :locales => [:en, :ka], :attributes => [:description]

  apply_simple_captcha

  def self.image_storage
    Rails.cache.fetch(CACHE_IMAGE_STORAGE) {Setting.find_or_create_by(key: 'image_storage').value}
  end

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(cat_nav_state, searched_item, selected_item_ids, user_action, ad_id)

    if ad_id.present?
      # Search by ad ids when adding ads on home page dynamically, when other user just created an ad (websocket)
      ads = Ad.find(ad_id)
      ads = [ads.marker_info]
    else
      ads = Ad.select(:marker_info).where("expire_date >= ? and (marker_info->>'ad_id') is not null", Date.today)

      if cat_nav_state || searched_item
        if cat_nav_state
          if searched_item
            # We search for ads in relation to the searched item and the current category navigation state.
            ads = ads.joins([:items, :categories]).where(categories: {id: cat_nav_state}, items: {id: selected_item_ids})
          else
            # We search for ads in relation to our current category navigation state.
            ads = ads.joins(:categories).where(categories: {id: cat_nav_state})
          end
        elsif searched_item
          ads = ads.joins(:items).where(items: {id: selected_item_ids})
        end
      end

      if user_action
        # If the user is searching for items, we need to show the posted ads, which people give stuff away.
        ads = ads.where("ads.is_giving = ?", user_action == 'searching')
      end

      ads = ads.pluck(:marker_info)

    end

    ads

  end



  # method used to save the ads#new form. A captcha is required when the user is anonymous.
  # In that case the save method is different than the classic one.
  def save_with_or_without_captcha(current_user)
    if current_user
      self.save
    else
      self.is_username_used = false
      self.save_with_captcha
    end
  end

  def has_items
    errors.add(:base, I18n.t('ad.error_ad_must_have_item')) if (self.ad_items.blank? || self.ad_items.empty?)
  end

  def has_locations
    errors.add(:base, I18n.t('ad.error_ad_must_have_location')) if (self.ad_locations.blank? || self.ad_locations.empty?)
  end

  def has_anon_name_and_email
    errors.add(:base, I18n.t('ad.provide_anon_name')) if (self.user_id.nil? && self.anon_name.blank?)
    errors.add(:base, I18n.t('ad.provide_anon_email')) if (self.user_id.nil? && self.anon_email.blank?)
  end

  def must_have_one_category
    errors.add(:base, I18n.t('ad.error_ad_must_have_category')) if (self.categories.blank? || self.categories.empty?)
  end

  def no_user_at_all
    self.anon_email == nil && self.user == nil
  end


  # The publisher of an ad might not want to have their full name publicly displayed.
  # This method defines whether to show the username or the full name (whether it is anonymous or registered user)
  def username_to_display
    if self.is_anonymous
      self.anon_name
    elsif self.is_username_used
      self.user.username
    else
      "#{self.user.first_name} #{self.user.last_name}"
    end
  end

  # If we deal with an anonymous ad publisher, we get the email from the ad itself (no user model created)
  # Otherwise we get the email from the user model linked to the ad.
  def email_to_display
    if self.no_user_at_all
      I18n.t('ad.no_user_tied_yet')
    elsif self.is_anonymous
      self.anon_email
    else
      self.user.email
    end
  end

  def has_expired
    self.expire_date < Date.today
  end

  # Define whether or not this ad has been created by a signed-in or an anonymous user.
  def is_anonymous
    (self.user_id == nil || self.user_id == 0) && self.anon_name != nil
  end

  def thumb_image_url
    self.image_url(:thumb)
  end

  def recreate_delayed_versions!
    self.image.is_processing_delayed = true
    self.image.recreate_versions!
  end

  # To be used in the map popup, on ads#show page.
  def item_list
    result = []
    self.ad_items.each do |ad_item|
      result << ad_item.item.capitalized_name
    end
    return result.join(', ')
  end

  def is_a_favorite_of(user)
    result = false
    if user && user.favorite_ads
      favorite_ads = user.favorite_ads.pluck(:id)
      result = favorite_ads.include?(self.id)
    end
    return result
  end

  private

  # Setting default values after initialization, on ads#new
  def default_values
    if self.new_record?
      self.is_username_used = false
      self.is_published = false
      self.is_giving = true

      # we define the date when the ad won't be published any longer (see maximum number of days, in Settings table)
      if max_number_days_publish == '0'
        # No limit set for ad expiration. Let's use 2100-01-01 as a default date value
        self.expire_date = Date.new(2100,1,1)
      else
        d = Date.today
        self.expire_date = d + max_number_days_publish.to_i
      end
    end
  end

end
