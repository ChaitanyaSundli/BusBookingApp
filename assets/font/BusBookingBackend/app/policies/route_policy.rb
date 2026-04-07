class RoutePolicy < ApplicationPolicy
  # only admin can create/update/delete routes
  def create?  = user.admin? || user.operator?
  def update?  = user.admin? || user.operator?
  def destroy? = user.admin? || user.operator?

  # everyone can view routes
  def show?  = true
  def index? = true

  class Scope < Scope
    def resolve
      return scope.all    if user.admin?
      scope.where(is_active: true)
    end
  end
end