# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    sequence(:name) { |n| "A Card #{n}" }
    description "A card description"
    source "device"
    sequence(:short_id) { |n| n }
    stack
    user
  end
end
