module HomeHelper

  # Devise resources related methods
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def user_search_action
    search_action = nil
    user_action = params[:q]
    searched_term = params[:item]

    if user_action && searched_term
      # For the user action's "delete refinement" url, we need to get rid of empty parameters, like 'item=' or 'location='.
      # That's why we have elem[-1], in the delete_if clause.
      if user_action == 'searching'
        search_action = t('home.searching_for')
      elsif user_action == 'giving'
        search_action = t('home.giving_away')
      end
    end

    return search_action
  end

  def short_description_for(desc)
    desc.length > 100 ? "#{desc[0..96]}..." : desc
  end

  def colored_items_for(ad)
    it = []
    ad.items.each do |item|
      it << "<span style=\"color: #{item.category.color_code}\">#{item.name}</span>"
    end
    it.join(', ').html_safe
  end

  def result_icon_for(location)
    dot_circle_icon = "<i class='fa fa-dot-circle-o' aria-hidden='true'></i>"
    map_marker_icon = "<i class='fa fa-map-marker' aria-hidden='true'></i>"
  end

end
