FactoryGirl.define do
  factory :admin do
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password "please123"
  end
end
