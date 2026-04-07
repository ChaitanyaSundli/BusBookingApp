class Fare < ApplicationRecord
  belongs_to :route
  belongs_to :operator, class_name: 'User', foreign_key: :operator_id

  enum :bus_type, {
    ac_seater: 0,
    non_ac_seater: 1,
    ac_sleeper: 2,
    non_ac_sleeper: 3
  }, prefix: true

  validates :bus_type, :base_fare_per_km, :min_fare, presence: true
  validates :bus_type, uniqueness: { scope: %i[route_id operator_id] }
end
