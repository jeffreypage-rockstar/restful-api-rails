# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :network do
    provider "tumblr"
    sequence(:uid) { |n| "000001#{n}" }
    sequence(:token) { |n| "abdcef#{n}" }
    sequence(:secret) { |n| "zyxvu#{n}" }
    user
  end
end
