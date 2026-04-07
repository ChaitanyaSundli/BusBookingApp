class BookingPolicy < ApplicationPolicy
  def create?
    user.passenger? && record.trip.scheduled?
  end

  def show?
    user.passenger? && record.user_id == user.id
  end

  def index?
    user.passenger?
  end

  def cancel?
    user.passenger? && record.user_id == user.id && record.confirmed?
  end
end
