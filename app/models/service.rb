class Service < ActiveRecord::Base
  include Nameable

    has_ancestry

  # globalize

    translates :name, :description
    globalize_accessors :locales => [:en, :ka], :attributes => [ :name, :description]

  # associations

    belongs_to :place

  # scopes

    def self.sorted
      with_translations(I18n.locale).order(sort: :asc, name: :asc)
    end

  # validators

    validates :icon, presence: true, if: Proc.new { |x| x.ancestry.blank? }

    I18n.available_locales.each do |locale|
      validates :"name_#{locale}", presence: true
      # validates :"description_#{locale}", presence: true
    end
end
