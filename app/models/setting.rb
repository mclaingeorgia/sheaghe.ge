class Setting < ActiveRecord::Base

  # Fields to be translated
  translates :value
  SOCIAL_MEDIAS = %w(facebook twitter pinterest)

  scope :social_medias, lambda { where key: SOCIAL_MEDIAS}

  def self.maptypes
    %w(osm mapbox mapquest)
  end

  def self.description
    description = Setting.find_by_key(:description)
    description.present? ? description.value.split(/[\r\n]+/) : ''
  end

  def self.contact_email
    Setting.find_by_key(:contact_email)
  end

  def url
    key == 'twitter' ? "http://twitter.com/#{value}" : "http://#{value}"
  end

end
