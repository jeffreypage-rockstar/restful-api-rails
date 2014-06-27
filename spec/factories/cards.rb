# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    name 'A Card'
    description 'A card description'
    stack
    user
  end
end
