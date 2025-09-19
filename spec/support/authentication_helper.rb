
module AuthenticationHelper
  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password || 'password'
      }
    }
    follow_redirect! if response.redirect?
  end


end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
