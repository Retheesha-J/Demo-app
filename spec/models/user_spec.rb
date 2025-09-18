require 'rails_helper'

RSpec.describe User, type: :model do
  
  describe "Validations" do
    it "is valid with valid attributes" do
      user=build(:user)
      expect(user).to be_valid
    end
    
    it "is invalid without a name" do
      user=build(:user,name:"")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is invalid without an email" do
      user=build(:user,email:"")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid if email is not unique" do
      existing_user = create(:user)
      duplicate_user = build(:user, email: existing_user.email)
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end

    it "is invalid if password is  too short" do
      user=build(:user,password:"123")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "is invalid if emailformat is wrong" do
      user=build(:user,email:"Invalid_email")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end
  end


end
