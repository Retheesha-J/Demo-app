require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:admin_user) { create(:user, role: 'admin', password: 'password') }
  let!(:regular_user) { create(:user, role: 'user', password: 'password') }
  let!(:support_user) { create(:user, role: 'support', password: 'password') }

  before do
   sign_in admin_user
  end
  def json
    JSON.parse(response.body)["data"]
  end
  def meta
    JSON.parse(response.body)["meta"]
  end

  describe "GET /users" do
        before do
          User.delete_all
          @admin   = create(:user, role: "admin",   name: "Admin Admin",     email: "admin@example.com")
          @support = create(:user, role: "support", name: "Support Support", email: "support@example.com")
          @regular = create(:user, role: "user",    name: "Retheesha User",  email: "regular@example.com")
          sign_in @admin
        end

        context "filtering" do
          it "filters by role" do
            get users_path, params: { q: { role_eq: "user" } }, as: :json
            expect(response).to have_http_status(:ok)
            expect(json.map { |u| u["name"] }).to contain_exactly("Retheesha User")
          end

          it "filters by email containing 'support'" do
            get users_path, params: { q: { email_cont: "support" } }, as: :json
            expect(json.map { |u| u["email"] }).to include("support@example.com")
            expect(json.map { |u| u["email"] }).not_to include("admin@example.com")
          end

          it "filters by name containing 'Retheesha'" do
            get users_path, params: { q: { name_cont: "Retheesha" } }, as: :json
            expect(json.map { |u| u["name"] }).to contain_exactly("Retheesha User")
          end
        end

        context "sorting" do
          it "sorts by name ascending" do
            get users_path, params: { q: { s: "name asc" } }, as: :json
            expect(json.map { |u| u["name"] }).to eq(["Admin Admin", "Retheesha User", "Support Support"])
          end

          it "sorts by name descending" do
            get users_path, params: { q: { s: "name desc" } }, as: :json
            expect(json.map { |u| u["name"] }).to eq(["Support Support", "Retheesha User", "Admin Admin"])
          end
        end
  end
  describe "GET/Users with pagination" do
    before do
      User.delete_all
        @admin = create(:user, role: "admin")
        sign_in @admin  
        create_list(:user, 14, role: 'user')
    end

    it "returns the first page of users by default" do
      get users_path,as: :json

      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(5)
      expect(meta["page"]).to eq(1)
      expect(meta["per_page"]).to eq(5)
      expect(meta["total_pages"]).to eq(3)
      expect(meta["total_count"]).to eq(15)
    end

    it "returns the custom page size" do
      get users_path,params:{per_page:10},as: :json

      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(10)
      expect(meta["page"]).to eq(1)
      expect(meta["per_page"]).to eq(10)
      expect(meta["total_pages"]).to eq(2)
      expect(meta["total_count"]).to eq(15)
    end

    it "returns second page correctly" do
      get users_path,params:{per_page:7,page:3},as: :json

      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(1)
      expect(meta["page"]).to eq(3)
      expect(meta["per_page"]).to eq(7)
      expect(meta["total_pages"]).to eq(3)
      expect(meta["total_count"]).to eq(15)

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
        patch user_path(regular_user), params: { 
                  user: { 
                    name: 'New Name', 
                    email: regular_user.email, 
                    password: 'password', 
                    password_confirmation: 'password' 
                  } 
                }
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
        sign_out admin_user
        
        post user_session_path, params: { 
          user: { email: admin_user.email, password: 'password' } 
        }
        
       expect(response).to redirect_to(dashboard_path)
      end
    end

    context "with invalid credentials" do
      it "redirects back to login" do
        sign_out admin_user
        
        post user_session_path, params: { 
          user: { email: admin_user.email, password: 'wrong_password' } 
        }
        
        expect(response).to have_http_status(:unprocessable_content)
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
      User.delete_all
      create_list(:user, 3, role: 'user')
      expect {
        post send_bulk_emails_users_path,as: :json
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob).exactly(3).times
      expect(response).to have_http_status(:redirect)
    end
  end


end
