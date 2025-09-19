class UserPolicy < ApplicationPolicy
  def create?
    user.role == "admin"
  end

  def update?
    user.role == "admin"
  end

  def destroy?
    user.role == "admin"
  end

  def send_email?
    user.role.in?(%w[admin support])
  end

  def send_bulk_emails?
    user.role.in?(%w[admin support])
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
