class TripPolicy < ApplicationPolicy
  def create?  = user.operator? && user.bus_operators.present?
  def update?  = user.admin? || owned_by_operator?
  def destroy? = user.admin? || owned_by_operator?
  def cancel?  = user.admin? || owned_by_operator?
  def show?    = true
  def index?   = true

  class Scope < Scope
    def resolve
    return scope.all unless user
    return scope.all if user.admin?
    if user.operator?
      scope.joins(:bus)
           .where(buses: { bus_operator_id: user.bus_operators&.first&.id })
    else
      scope.where(status: :scheduled)
    end
    end
  end

  private

  def owned_by_operator?
    user.operator? &&
      record.bus.bus_operator_id == user.bus_operators&.first&.id
  end
end