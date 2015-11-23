class User::CategoriesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :init_icons_to_propose
  after_action :verify_authorized
  after_action :update_ad_json, only: [:update]

  def show
    @category = Category.find(params[:id])
    authorize @category

    render 'category'
  end

  def new
    @isAdding = true
    @category = Category.new
    authorize @category

    @category.icon = 'fa-circle' #default icon

    render 'category'
  end

  def create
    @category = Category.new(category_params)
    authorize @category

    if @category.save
      flash[:new_name] = @category.name
      redirect_to edit_user_category_path(@category.id)
    else
      @isAdding = true
      render 'category'
    end
  end

  def edit
    @category = Category.find(params[:id])
    authorize @category

    render 'category'
  end

  def update
    @category = Category.find(params[:id])
    authorize @category

    if @category.update(category_params)
      flash[:name] = @category.name
      redirect_to edit_user_category_path
    else
      render 'category'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    authorize @category

    deleted_category_name = @category.name
    if @category.destroy
      flash[:success] = t('admin.category.success_deleted', name: deleted_category_name)
      redirect_to user_managerecords_path
    else
      @available_colors = MarkerColor.pluck(:id, :name)
      render 'category'
    end

  end

  private

  def category_params
    params.require(:category).permit(:name, :name_en, :name_ka, :description, :description_en, :description_ka, :icon, :marker_color)
  end

  # Updates the relevant ads marker_info (jsonb) and update the marker color and marker icon in the 'markers' nested array.
  def update_ad_json
    category = Category.find(params[:id])
    ads = Ad.joins(:categories).where(categories: {id: params[:id]})
    ads.each do |ad|
      if !ad.marker_info.empty?
        marker_info = ad.marker_info
        marker_info['markers'].each do |item|
          if item['category_id'] == params[:id].to_i
            item['color'] = category.marker_color
            item['icon'] = category.icon
          end
        end
        ad.marker_info = marker_info
        ad.save
      end
    end
  end

  def init_icons_to_propose
    count = 0
    keywords = []
    @icon_keyword_list = []
    ICON_SELECTION.each do |icon|
      keywords << icon
      count += 1
      if count == 4
        @icon_keyword_list << keywords
        count = 0
        keywords = []
      end
    end
  end

end
