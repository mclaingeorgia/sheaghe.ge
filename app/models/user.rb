class User < ActiveRecord::Base

  enum role: [:user, :admin, :super_admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
    self.role ||= :user
  end

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :first_name, :last_name, :username, presence: true
  validates :is_service_provider, inclusion: [true, false]
  validates_uniqueness_of :username

  has_many :locations, dependent: :destroy
  has_many :ads, dependent: :destroy
  has_many :ad_users
  has_many :favorite_ads, through: :ad_users, source: :ad

  def owns_ad (ad)
    self.ads.include?(ad)
  end

  def is_admin_or_super_admin
    self.admin? || self.super_admin?
  end
end
