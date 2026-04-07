class BusOperator < ApplicationRecord
  belongs_to :user
  has_many  :buses, dependent: :destroy
  has_many  :reviews, dependent: :destroy

  validates :company_name, presence: true
  validates :license_no, presence: true, uniqueness: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  scope :verified, -> { where(is_verified: true)}
end
