class BookingSeat < ApplicationRecord
  belongs_to :booking
  belongs_to :trip_seat
  belongs_to :passenger

  validates :seat_price, numericality: { greater_than_or_equal_to: 0 }
end
