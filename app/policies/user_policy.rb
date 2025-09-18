class UserPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def send_email?
    user.admin? || user.support?
  end

  def send_bulk_emails?
    user.admin? || user.support?
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def  resolve 
      scope.all
    end
  end
end
