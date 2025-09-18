FactoryBot.define do
    factory :user do
        name {"Test user"}
        email {"testuser#{SecureRandom.hex(4)}@test.com"}
        password {"password"}
        role {"user"}
        trait :admin do
           role { "admin" }
        end
        trait :support do
            role { "support" }
        end
    end
end
