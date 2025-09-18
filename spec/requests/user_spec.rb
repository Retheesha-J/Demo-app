require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:admin_user) { create(:user, role: 'admin', password: 'password') }
  let(:regular_user) { create(:user, role: 'user', password: 'password') }
  let(:support_user) { create(:user, role: 'support', password: 'password') }

  before do
    # Mock the current_user method to return an admin user
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin_user)
  end

  describe "GET /users" do
    it "returns a successful response" do
      get users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:id" do
    it "shows the user" do
      get user_path(regular_user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post users_path, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "with invalid parameters" do
      it "does not create a user" do
        expect {
          post users_path, params: { user: { email: '' } }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /users/:id" do
    it "updates the user" do
      patch user_path(regular_user), params: { user: { name: 'New Name' } }
      expect(response).to have_http_status(:redirect)
      regular_user.reload
      expect(regular_user.name).to eq('New Name')
    end
  end

  describe "DELETE /users/:id" do
    it "deletes the user" do
      user_to_delete = create(:user)
      expect {
        delete user_path(user_to_delete)
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "POST /login" do
    context "with valid admin credentials" do
      it "logs in and redirects to dashboard" do
        # For login tests, don't mock current_user so we can test actual login
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_call_original
        
        post login_path, params: { 
          user: { email: admin_user.email, password: 'password' } 
        }
        
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid credentials" do
      it "redirects back to login" do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_call_original
        
        post login_path, params: { 
          user: { email: admin_user.email, password: 'wrong_password' } 
        }
        
        expect(response).to have_http_status(:ok)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST /users/:id/send_email" do
    it "enqueues a welcome email for the user" do
      expect {
        post send_email_user_path(regular_user)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "POST /users/send_bulk_emails" do
    it "enqueues emails for all users with role 'user'" do
      create_list(:user, 3, role: 'user')
      expect {
        post send_bulk_emails_users_path
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(3).times
      expect(response).to have_http_status(:redirect)
    end
  end
end