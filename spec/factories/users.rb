FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password 'please123'
    confirmed_at 1.day.ago
  end
end
