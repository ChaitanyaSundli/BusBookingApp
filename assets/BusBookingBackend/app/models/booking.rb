class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  belongs_to :boarding_stop, class_name: 'RouteStop', foreign_key: :boarding_stop_id
  belongs_to :drop_stop,     class_name: 'RouteStop', foreign_key: :drop_stop_id

  enum :status, {
    pending:   'pending',
    confirmed: 'confirmed',
    cancelled: 'cancelled',
    failed:    'failed'
  }

  has_many :booking_seats, dependent: :destroy
  has_many :trip_seats,    through: :booking_seats
  has_many :passengers,    through: :booking_seats
  has_many :payments,      dependent: :destroy
  validates :total_price,   numericality: { greater_than_or_equal_to: 0 }
end