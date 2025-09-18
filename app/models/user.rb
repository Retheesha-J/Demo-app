class User < ApplicationRecord


    has_secure_password
    validates :role, presence: true
    validates :name,presence:true
    validates :email,presence:true

    validates :email,uniqueness:true

    validates :password,length:{minimum:6}

    validates :email,format: {with: URI::MailTo::EMAIL_REGEXP} 

    before_validation :set_default_role, on: :create

    def admin?
        role == "admin"
    end

    def support?
        role == "support"
    end

    def user?
        role == "user"
    end

    private
    def set_default_role
        self.role ||= "user"
    end
end
