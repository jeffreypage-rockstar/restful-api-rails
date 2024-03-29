FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:facebook_id) { |n| "000001#{n}" }
    sequence(:facebook_token) { |n| "abdcef#{n}" }
    avatar_url "http://placehold.it/80x80"
    password "please123"
    location "New York, NY"

    confirmed_at 1.day.ago

    factory :user_with_valid_fb do
      facebook_id Rails.application.secrets.fb_valid_user_id
      facebook_token Rails.application.secrets.fb_valid_token
    end
  end
end
