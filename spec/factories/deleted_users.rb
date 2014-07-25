FactoryGirl.define do
  factory :deleted_user do
    sequence(:id) { |n| "1640cd3e-ba63-4cda-929d-c1eccc3d5#{"%02d" % n}a" }
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:facebook_id) { |n| "000001#{n}" }
    sequence(:facebook_token) { |n| "abdcef#{n}" }
    avatar_url "http://placehold.it/80x80"
    location "New York, NY"
    encrypted_password "DbhF4CyhO3ZJjPk4CkIiV29t4a4rMJkM48SjUIMi"

    confirmed_at 1.day.ago
    deleted_at 0.days.ago
    sign_in_count 10
  end
end
