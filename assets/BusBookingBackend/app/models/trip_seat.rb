class TripSeat < ApplicationRecord
  belongs_to :trip
  belongs_to :seat
  belongs_to :locked_by_user, class_name: 'User', foreign_key: :locked_by_user, optional: true
  has_many   :booking_seats,  dependent: :destroy

  enum :status, {
    available: 'available',
    locked:    'locked',
    booked:    'booked'
  }

  validates :seat_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :available,            -> { where(status: 'available') }
  scope :with_expired_locks,   -> { where(status: 'locked').where('lock_expiry_time < ?', Time.current) }
end