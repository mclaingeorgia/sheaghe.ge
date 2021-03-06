# == Schema Information
#
# Table name: page_content_items
#
#  id              :integer          not null, primary key
#  page_content_id :integer
#  order           :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class PageContentItem < ActiveRecord::Base
  include Nameable

  belongs_to :page_content
  # globalize

    translates :title, :content
    globalize_accessors :locales => [:en, :ka], :attributes => [:title, :content]

  # scopes

    def self.sorted
      order(order: :asc)
    end

  # validators

    # validates :name, presence: true, uniqueness: true
    I18n.available_locales.each do |locale|
      validates :"title_#{locale}", presence: true
      validates :"content_#{locale}", presence: true
    end

  # getters

    # def self.by_name(name)
    #   find_by(name: name)
    # end

end
