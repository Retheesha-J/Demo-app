require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:admin)   { build(:user, role: "admin") }
  let(:support) { build(:user, role: "support") }
  let(:regular) { build(:user, role: "user") }

  permissions = {
    create?:    [:admin],
    update?:    [:admin],
    destroy?:   [:admin],
    send_email?: [:admin, :support],
    send_bulk_emails?: [:admin, :support],
    index?:     [:admin, :support, :user],
    show?:      [:admin, :support, :user]
  }

  permissions.each do |action, roles|
    describe "##{action}" do
      roles.each do |role|
        it "permits #{role}" do
          user = build(:user, role: role.to_s)
          policy = UserPolicy.new(user, build(:user))
          expect(policy.public_send(action)).to be true
        end
      end

      it "forbids others" do
        disallowed_roles = %w[admin support user] - roles.map(&:to_s)
        disallowed_roles.each do |role|
          user = build(:user, role: role)
          policy = UserPolicy.new(user, build(:user))
          expect(policy.public_send(action)).to be false
        end
      end
    end
  end
end
