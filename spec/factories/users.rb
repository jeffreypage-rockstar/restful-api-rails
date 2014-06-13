FactoryGirl.define do
  factory :user do
    username 'testuser'
    email 'test@example.com'
    password 'please123'
    confirmed_at 1.day.ago
  end
end
