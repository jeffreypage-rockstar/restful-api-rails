# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :network do
    provider "facebook"
    sequence(:uid) { |n| "000001#{n}" }
    sequence(:token) { |n| "abdcef#{n}" }
    sequence(:secret) { |n| "zyxvu#{n}" }
    sequence(:username) { |n| "username#{n}" }
    user
  end
end
