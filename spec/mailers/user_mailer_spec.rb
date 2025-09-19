require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe "welcome_email" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.welcome_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to MyApp")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["retheesha2002@outlook.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Welcome") # or user.name if you include it
    end
  end
end
