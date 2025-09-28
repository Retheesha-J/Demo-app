class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    has_many :documents, dependent: :destroy

    validates :role, presence: true
    validates :name,presence:true
    validates :email,presence:true

    validates :email,uniqueness:true

    validates :password,length:{minimum:6}

    validates :email,format: {with: URI::MailTo::EMAIL_REGEXP} 

    before_validation :set_default_role, on: :create

      def self.ransackable_attributes(auth_object = nil)
        ["id", "name", "email", "role", "created_at", "updated_at"]
    end

    def self.ransackable_associations(auth_object = nil)
        []
    end

    private
    def set_default_role
        self.role ||= "user"
    end
end
