class FarePolicy < ApplicationPolicy
  def create?  = user.operator? && user.bus_operators.present?
  def update?  = user.admin? || owned_by_operator?
  def destroy? = user.admin? || owned_by_operator?
  def show?    = true
  def index?   = true

  class Scope < Scope
    def resolve
      return scope.all if user.admin?
      scope.where(operator_id: user.id)
    end
  end

  private

  def owned_by_operator?
    user.operator? && record.operator_id == user.id
  end
end