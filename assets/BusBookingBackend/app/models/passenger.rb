class Passenger < ApplicationRecord
  has_many :booking_seats, dependent: :destroy
  GENDERS = %w[male female other].freeze
  validates :name,   presence: true
  validates :age,    presence: true, numericality: { greater_than: 0, less_than: 120 }
  validates :gender, presence: true, inclusion: { in: GENDERS }
end
