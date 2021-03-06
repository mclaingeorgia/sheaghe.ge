# == Schema Information
#
# Table name: assets
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  owner_id   :integer
#  owner_type :integer
#  image      :string
#

class Asset < ActiveRecord::Base
  belongs_to :place

  mount_uploader :image, ImageUploader

  validates_processing_of :image
  validate :image_size_validation

  has_many :uploads

  private
    def image_size_validation
      errors[:image] << "should be less than 2MB" if image.size > 2.megabytes
    end
end

