class Passenger < ApplicationRecord
  has_many :booking_seats, dependent: :destroy

  enum :gender, { male: 0, female: 1, other: 2 }

  validates :name, presence: true
  validates :age, presence: true, numericality: { greater_than: 0, less_than: 120 }
  validates :gender, presence: true
end
