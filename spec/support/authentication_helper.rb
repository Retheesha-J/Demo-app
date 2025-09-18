module AuthenticationHelper
  def sign_in(user)
    # For request specs, we need to manually set the session
    post login_path, params: { 
      user: { 
        email: user.email, 
        password: user.password || 'password' 
      } 
    }
  end

  # Alternative: Directly mock the current_user method
  def mock_current_user(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end