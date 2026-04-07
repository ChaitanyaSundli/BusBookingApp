class Trip < ApplicationRecord
  belongs_to :bus
  belongs_to :route
  has_many :trip_seats, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy

 enum :status, { scheduled: 0, cancelled: 1, completed: 2 }
  validates :travel_start_date, :departure_time, :arrival_time, presence: true
  validate  :arrival_must_be_after_departure
  scope :upcoming, -> {
    where(status: 'scheduled').where('departure_time > ?', Time.current)
  }

  after_create :generate_trip_seats

  private
  def set_default_status
    self.status ||= :scheduled
  end
  def arrival_must_be_after_departure
    return unless departure_time && arrival_time
    if arrival_time <= departure_time
      errors.add(:arrival_time, "must be after departure time")
    end
  end

  def generate_trip_seats
    fare = route.fares.find_by(bus_type: bus.bus_type)
    bus.seats.each do |seat|
      price = fare ? fare.base_fare_per_km * route.total_distance_km : 0
      price = [price, fare&.min_fare || 0].max
      trip_seats.create!(
        seat:       seat,
        seat_price: price.round(2),
        status:     0
      )
    end
    update_column(:available_seats, bus.seats.count)
  end    
end
