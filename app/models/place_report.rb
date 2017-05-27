class PlaceReport < ActiveRecord::Base

  # processed
  # 0 - pending
  # 1 - accepted
  # 2 - declined

  belongs_to :user
  belongs_to :place

  # default_scope
  scope :pending, -> { where(processed: 0) }

  validates :user_id, :place_id, :reason, presence: true

  def self.requested?(user_id, place_id)
    find_by(user_id: user_id, place_id: place_id).present?
  end

  def self.request_report(user_id, place_id, reason)
    response = nil
    class_name = self.model_name.param_key

    r = find_by(user_id: user_id, place_id: place_id)

    if r.present? || PlaceReport.create(user_id: user_id, place_id: place_id, reason: reason)
      response = {type: :success, text: :succeed_to_process, action: class_name, forward: { refresh: { type: 'report' } }}
    end

  rescue Exception => e
     Rails.logger.debug("-------------------------------------------#{class_name}-#{e}") # only dev
  ensure
    return response.present? ? response : {type: :error, text: :failed_to_process, action: class_name}
  end

  def can_accept?
    [0,2].include?(self.processed)
  end
  def can_decline?
    [0,1].include?(self.processed)
  end
  def is_processed?
    [1,2].include?(self.processed)
  end
  def is_pending?
    [0].include?(self.processed)
  end
  def processed_human
    ['pending', 'accepted', 'declined'][self.processed]
  end

end
