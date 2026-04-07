class Seat < ApplicationRecord
  belongs_to :bus
  has_many   :trip_seats, dependent: :destroy

  enum :seat_type, { window: 'window', aisle: 'aisle', sleeper: 'sleeper', single: 'single' }
  
  validates :seat_number, :seat_type, :deck, presence: true
  validates :seat_number, uniqueness: { scope: :bus_id }
  validates :row_number, :col_number, numericality: { greater_than: 0 }, allow_nil: true
end