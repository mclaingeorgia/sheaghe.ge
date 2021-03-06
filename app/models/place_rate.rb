# == Schema Information
#
# Table name: place_rates
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  place_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#  value      :integer
#

class PlaceRate < ActiveRecord::Base
  belongs_to :user
  belongs_to :place

  after_commit :calculate_place_rating

  validates :user_id, :place_id, :value, presence: true

  def calculate_place_rating
    r = PlaceRate.where(place_id: self.place_id)
    p = Place.find_by(id: self.place_id)
    avg = r.present? ? (r.sum(:value)+0.0)/r.count() : 0
    p.update_attribute(:rating, avg) if p.present?
  end

  def self.rate(user_id, place_id, value)
    response = nil
    class_name = self.model_name.param_key

    r = find_by(user_id: user_id, place_id: place_id)
    if value > 0 && value <= 5
      if r.present? ? r.update({value: value}) : PlaceRate.create(user_id: user_id, place_id: place_id, value: value)
        response = {type: :success, text: :succeed_to_process, action: class_name,
          forward: { refresh: { type: 'rate', to: [value, Place.find_by(id: place_id).get_rating], place_id: place_id } }}
      end
    elsif value == 0
      r.destroy if r.present?
      response = {type: :success, text: :succeed_to_process, action: class_name,
        forward: { refresh: { type: 'rate', to: [value, Place.find_by(id: place_id).get_rating], place_id: place_id } }}
    end
  rescue Exception => e
     Rails.logger.debug("-------------------------------------------#{class_name}-#{e}") # only dev
  ensure
    return response.present? ? response : {type: :error, text: :failed_to_process, action: class_name}
  end


  def self.get_rate(user_id, place_id)
    r = find_by(user_id: user_id, place_id: place_id)
    r.present? ? r.value : 0
  end
end
