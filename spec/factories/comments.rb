# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    body "A comment wihout mentions"
    user
    card
  end
end
