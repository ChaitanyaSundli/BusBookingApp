class RouteStop < ApplicationRecord
  belongs_to :route

  validates :city_name, :stop_name, :stop_order, presence: true
  scope :boarding_points, -> { where(is_boarding_point: true) }
  scope :drop_points,     -> { where(is_drop_point: true) }
  scope :ordered,         -> { order(:stop_order) }
end
 