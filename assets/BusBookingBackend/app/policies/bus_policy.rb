class BusPolicy < ApplicationPolicy
 def create?
  return false unless user.operator?
  return false unless record.bus_operator.present?
  user.bus_operators.exists?(id: record.bus_operator.id)
 end

  def show?    = true
  def index?   = true

  def update?  = user.admin? || owned_by_operator?
  def destroy? = user.admin? || owned_by_operator?

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.operator?
        scope.where(bus_operator_id: user.bus_operators.pluck(:id))
      else
        scope.active
      end
    end
  end

  private

  def owned_by_operator?
    user.operator? && record.bus_operator_id.in?(user.bus_operators.pluck(:id))
  end
end