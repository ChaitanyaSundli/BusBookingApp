class PaymentPolicy < ApplicationPolicy
  def create?
    user.passenger? && record.booking.user_id == user.id && record.booking.pending?
  end
end