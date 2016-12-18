class HomeController < ApplicationController
  include ApplicationHelper

  # --------------------------------------
  # Method for the main screen (home page)
  # --------------------------------------
  def index
    # Initializing the map, in relation to its center, defined in the settings table.
    @map_settings = MapInfo.new.to_hash

    # Initializing links, and social media information, for the footer of the home page.
    settings = get_footer_info

    # We check if the user searched for an item and/or a location
    if params[:item] && params[:item] != ''
      # An item is being searched.
      selected_item_ids = Item.joins(:ads).where('name LIKE ?', "%#{params[:item].downcase}%").pluck(:id).uniq
    end

    if (params[:zoom])
      @map_settings['my_zoom'] = params[:zoom]
    end

    # if (params[:lat] && params[:lon])
    #     # The center of the map is now represented by the searched location.
    #     @map_settings[:latitude] = params[:lat]
    #     @map_settings[:longitude] = params[:lon]
    #
    #     current_location, popup_html = current_location_for(params)
    #     @map_settings[:searched_address] = popup_html
    #     @location_search_refinement_to_display = current_location
    # end

    # Defining all the categories attached to an item.
    if selected_item_ids
      # We select here only the categories, based on the items found after a search.
      @categories = Category.joins(ads: :items).where("items.id IN (?)", selected_item_ids).order('name asc').uniq
    else
      # We select the categories related to all available items
      @categories = Category.joins(:ads).order('name asc').uniq
    end

    # We need to see if we have a navigation state.
    # If we do, that will impact what will be displayed on the map.
    if params[:cat]
      cat_nav_state = params[:cat].split(" ")
    end

    # We need to see if we have a navigation state. If we do, that will impact what will be displayed on the map.
    cat_nav_state = params[:cat].split(" ") if params[:cat]

    # Queries to get ads to be displayed on the map, based on their locations
    location_search_result_objects(params, cat_nav_state, selected_item_ids, settings)
  end


  # -------------------------
  # Method for the About page
  # -------------------------
  def about
    keys = %w(contact_email)
    description_key = "description_#{I18n.locale.to_s}"
    keys << description_key
    settings = Setting.where(key: keys)
    settings.each do |setting|
      if setting['key'] == description_key && setting['value'] != ''
        @website_description_paragraph = setting['value'].split(/[\r\n]+/)
      end
      if setting['key'] == 'contact_email' && setting['value'] != ''
        @contact_email = setting['value']
      end
    end

    render 'home/about'
  end

  def tos
    if current_user.nil? || (current_user && current_user.has_agreed_to_tos)
      redirect_to root_path
    end
    render 'home/tos'
  end

  def update_tos
    if params['has_agreed_to_tos'].nil? || params['has_agreed_to_tos'] == false
      flash[:error] = t('admin.profile.please_agree')
      redirect_to tos_path
    else
      current_user.has_agreed_to_tos = true
      current_user.save
      redirect_to user_path
    end
  end

  # -------------------------
  # Method for the FAQ page
  # -------------------------
  def faq
    render 'home/faq'
  end

  # ------------------
  # Search result page
  # ------------------
  def results
    id = params[:area].to_i
    @ads = Ad.includes(:location).where(locations: {area_id: id})
               .paginate(page: params[:page] || 1, per_page: 10 )

    @area = Area.find(id)
    render 'home/results'
  end

  # Method called by Ajax call made when marker on the home page is clicked.
  # Returns the HTML code that will create the popup linked to that marker.
  def show_ad_popup
    popup_html = ''
    begin
      ad_id = params['ad_id']
      location_id = params['location_id']
      category_id = params['category_id']
      page = params['page']

      ad = Ad.joins([:translations, {locations: :translations}, {categories: :translations}]).where(id: ad_id).first
      cats = ad.categories
      number_of_categories = cats.count
      item = cats.map(&:name).join(', ')
      title = ad.title.length > 40 ? ad.title.chomp(a[-3..-1]) + '...' : ad.title


      popup_html = "<div style='overflow: auto;'>"
      popup_html += "<div class='col-xs-12 title-popup' style='background-color: #{item.category.color_code}'>" +
                    "<span>#{title.capitalize}</span></div>"

      if ad.image?
        image_tag = ActionController::Base.helpers.image_tag(ad.image.normal.url)
        popup_html += "<div class='col-xs-12 image-popup no-padding'>#{image_tag}</div>"
      end

      # Title
      popup_html += "<div class='col-xs-12' style='margin-top: 15px;'>#{view_context.link_to(ad.title, ad)}</div>"

      # Action (giving away or searching for) + item name
      ad_action = ad.giving ? t('ad.giving_away') : t('ad.accepting')
      item_name = "<span style='color:" + item.category.color_code + "';><strong>" + item.name + "</strong></span>";
      and_other_items = number_of_items > 1 ? "and #{number_of_items - 1} other item(s)" : ''

      popup_html += "<div class='col-xs-12' style='margin-top: 15px;'>#{ad_action} #{item_name} #{and_other_items}</div>"

      # Location full address
      popup_html += "<div class='col-xs-12' style='margin-bottom: 15px;'>#{ad.location.full_address}</div>"

      # "Show details" button
      button = view_context.link_to(t('home.show_details'), ad, class: 'btn btn-info btn-sm no-color' )
      popup_html += "<div class='col-xs-12 button-popup'>#{button}</div>"

      popup_html += "</div>"

    rescue Exception => e
      p e
      p e.backtrace
      # An error occurred, we show a error message.
      popup_html = "<i>#{t('home.error_get_popup_content')}</i>"
    end

    render json: popup_html
  end

  def show_area_popup
    popup_html = ''
    begin
      area_id = params['area_id']

      area = Area.includes(locations: {ads: :items}).find(area_id.to_i)
      ad_count, item_count = 0, 0

      # Counting items for all ads in this area.
      area.locations.each do |location|
        ad_count += location.ads.count
        location.ads.each{|ad| item_count += ad.items.count}
      end

      message = I18n.t("home.area_marker_message", ad_count: ad_count, item_count: item_count)

      popup_html = "<div style='overflow: auto;'>"

      # Title
      popup_html += "<div class='col-xs-12 title-popup' style='background-color: #{Area::AREA_COLOR}'>" +
          "<span>#{area.name}</span></div>"

      # Message
      popup_html += "<div class='col-xs-12' style='margin: 15px 0px;'>#{message}</div>"

      # "Show details" button
      button = view_context.link_to(I18n.t('home.show_results'), results_path(area: area_id), class: 'btn btn-info btn-sm no-color' )
      popup_html += "<div class='col-xs-12 button-popup'>#{button}</div>"

      popup_html += "</div>"

    rescue Exception => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
      # An error occurred, we show a error message.
      popup_html = "<i>#{t('home.error_get_popup_content')}</i>"
    end
    
    render json: popup_html
  end

  def show_location_popup(content)
    popup_html = "<div style='overflow: auto;'>"

    # Title
    popup_html += "<div class='col-xs-12 title-popup' style='background-color: #{Area::AREA_COLOR}'>" +
        "<span>#{t('home.your_searched_location')}</span></div>"
    # Message
    popup_html += "<div class='col-xs-12' style='margin: 15px 0px;'>#{content}</div>"
    popup_html += "</div>"

    popup_html
  end

  def refine_state
    # From the home page, based on the selected navigation, get the relevant ads.

    state = params[:state]

    new_nav_states = state.split('&')
    nav_params = {}
    new_nav_states.each do |state|
      info = state.split('=')
      nav_params[info[0]] = info[1]
    end

    if nav_params['cat'] && nav_params['cat'] != ''
      selected_categories = nav_params['cat'].split('+')
    end

    if nav_params['item'] && nav_params['item'] != ''
      selected_item_ids = []

      # An item is being searched.
      searched_item = nav_params['item']
      selected_item_ids = Item.joins(:ads).where('name LIKE ?', "%#{searched_item}%").pluck(:id).uniq
    end

    response = {}
    response['map_info'] = {}
    response['map_info']['markers'] = Ad.search(selected_categories, searched_item, selected_item_ids, nav_params[:q], nil)

    #response['map_info']['area'] = Location.search('area', selected_categories, searched_item, selected_item_ids, nav_params[:q])
    #response['map_info']['area'] = Area.search(selected_categories, selected_item_ids, nav_params[:q])

    render json: response.to_json(:include => { :ads => { :include =>  {:items => { :include => :category }}}})
  end

  # Ajax call to show the ads related to 1 type of item and to 1 area
  # Call made when click on link, in area marker popup.
  def showSpecificAds
    item_name = params['item']
    location_type = params['type'] # 'postal', or 'area'
    area_value = params['area'] # code postal area code, or area id
    ads = Ad.joins(:location, :items).where('expire_date >= ? AND  items.name = ?', Date.today, location_type, item_name)
    item = Item.joins(:category).where('items.name = ?', item_name).first

    result = {}
    if location_type == 'postal'
      ads = ads.where('locations.postal_code LIKE ?', "#{area_value}%")
      result['area_name'] = area_value
    elsif location_type == 'area'
      ads = ads.where('locations.area_id = ?', area_value)
      result['area_name'] = Area.find(area_value).name
    end

    if item
      result['icon'] = item.category.icon
      result['hexa_color'] = item.category.marker_color_hexacode
    end

    result['ads'] = []
    ads.each do |ad|
      result['ads'] << {id: ad.id, title: ad.title, giving: ad.giving}
    end

    render json: result
  end

  private

  def location_search_result_objects(params, cat_nav_state, selected_item_ids, settings)
    # First, we get the ads tied to an exact location.
    @locations_exact = Ad.search(cat_nav_state, params[:item], selected_item_ids, params[:q], nil)

    # If the users have the possiblity to post ad linked to a pre-defined area, we also get here these type of ads.
    # locations_area = Location.search('area', cat_nav_state, params[:item], selected_item_ids, params[:q])

    # Getting a hash that matches areas to their respective latitude and longitudes.
    @areas = Area.all.select(:id, :name, :latitude, :longitude)
  end

  def current_location_for(params)
    # A location search was just performed, with the name of the searched location (given back from Nominatim ws) in it.
    return [params[:loc], show_location_popup(params[:loc])] if params.has_key?(:loc)

    # there was no search beforehand, we need to find the address, based on given latitude and longitude.
    current_location = address_from_geocodes(params[:lat], params[:lon])
    current_location = t('home.default_current_loc') if current_location.blank?

    [current_location, show_location_popup(current_location)]
  end

  # Creates a hash with the link and the label of one "Useful link",
  # that appears at the center of the home page footer.
  def get_link(label, label_ka, url)
    if label != '' && url != ''
      return {'label_en': label, 'label_ka': label_ka, 'url': url}
    end
  end

  # Get information ready for the footer of the home page
  # (eg. Website description, contact email, social media links... )
  # Also returns a settings hash, that will be needed for the rest of HomeController#index execution.
  def get_footer_info
    settings = {}
    Setting.all.each do |setting|
      settings[setting['key']]=setting['value']
    end

    # Useful links, for the footer section.
    link_numbers = %w(one two three four five six)
    @links = []
    link_numbers.each do |number|
      @links << get_link(settings["link_#{number}_label"], settings["link_#{number}_label_ka"], settings["link_#{number}_url"])
    end
    settings
  end

end
