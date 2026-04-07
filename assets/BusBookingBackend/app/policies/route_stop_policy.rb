class RouteStopPolicy < ApplicationPolicy
  def create?  = user.admin?
  def update?  = user.admin?
  def destroy? = user.admin?
  def show?    = true
  def index?   = true

  class Scope < Scope
    def resolve = scope.all
  end
end