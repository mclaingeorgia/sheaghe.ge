# == Schema Information
#
# Table name: place_services
#
#  id                             :integer          not null, primary key
#  place_id                       :integer          not null
#  service_id                     :integer          not null
#  created_at                     :datetime
#  updated_at                     :datetime
#  is_restricited_geographic_area :boolean
#  geographic_area_municipalities :integer          default([]), not null, is an Array
#  service_type                   :integer          default([]), not null, is an Array
#  act_regulating_service         :string
#  act_link                       :string
#  description                    :text
#  has_age_restriction            :boolean
#  age_groups                     :integer          default([]), not null, is an Array
#  can_be_used_by                 :integer
#  diagnoses                      :string           default([]), not null, is an Array
#  service_activities             :string           default([]), not null, is an Array
#  service_specialists            :string           default([]), not null, is an Array
#  need_finance                   :boolean
#  get_involved_link              :string
#

class PlaceService < ActiveRecord::Base
  include ActiveModel::Validations
  include Nameable

  # associations
    belongs_to :place
    belongs_to :service

  # enums
    SERVICE_TYPES = {"municipal": 1, "state": 2, "private_org": 3}
    AGE_GROUPS = {"0-6": 1, "7-18": 2, "18-65": 3, "65+": 4}
    CAN_BE_USED_BY = {"anyone": 1, "diagnosis_with_status": 2, "diagnosis_without_status": 3}
    enum can_be_used_by: CAN_BE_USED_BY

  # callbacks

    before_validation :remove_blanks
    before_save :remove_blanks

    def remove_blanks
      geographic_area_municipalities.reject!(&:blank?)
      service_type.reject!(&:blank?)
      age_groups.reject!(&:blank?)
      diagnoses.reject!(&:blank?)
      service_activities.reject!(&:blank?)
      service_specialists.reject!(&:blank?)
    end

  # validators

    validates :service_type, :description, :can_be_used_by, :service_activities, :service_specialists, presence: true
    validates :is_restricited_geographic_area, :has_age_restriction, inclusion: { in: [true, false] }
    validates :need_finance, inclusion: { in: [true, false, nil] }
    validate :optional_required_fields


    # when some fields have a certain value, other fields become required
    # is_restricited_geographic_area = no -> geographic_area_municipalities
    # has_age_restriction = no ->  age_groups
    # can_be_used_by = diagnosis_without_status -> diagnoses
    def optional_required_fields
      if self.is_restricited_geographic_area == true && self.geographic_area_municipalities.empty?
        self.errors.add(:geographic_area_municipalities, I18n.t('admin.shared.is_required'))
      end

      if self.has_age_restriction == true && self.age_groups.empty?
        self.errors.add(:age_groups, I18n.t('admin.shared.is_required'))
      end

      if self.can_be_used_by == 'diagnosis_without_status' && self.diagnoses.empty?
        self.errors.add(:diagnoses, I18n.t('admin.shared.is_required'))
      end
    end

  # helpers
    def self.validation_order_list
      [:is_restricited_geographic_area, :geographic_area_municipalities,
        :service_type, :act_regulating_service, :act_link, :description,
        :has_age_restriction, :age_groups, :can_be_used_by, :diagnoses,
        :service_activities, :service_specialists, :need_finance, :get_involved_link]
    end

  # scopes

    def self.service_types_for_list
      SERVICE_TYPES.map{|k,v| [v, I18n.t("activerecord.attributes.place_service.service_types.#{k}")]}
    end

    def self.age_groups_for_list
      AGE_GROUPS.map{|k,v| [v, k]}
    end

    def self.can_be_used_by_for_list
      CAN_BE_USED_BY.map{|k,v| [k, I18n.t("activerecord.attributes.place_service.can_be_used_bies.#{k}")]}
    end

  # methods

    def service_icon
      self.service.root? ? self.service.icon : self.service.parent.icon
    end

    def root_service_name
      self.service.root? ? self.service.name : self.service.parent.name
    end

end
