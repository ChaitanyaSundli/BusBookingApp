class Review < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  belongs_to :bus_operator
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :trip_id, message: 'already reviewed this trip' }
  validate :trip_must_be_completed

  private
  def trip_must_be_completed
    errors.add(:trip, 'must be completed before reviewing') unless trip&.completed?
  end
end