# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stack do
    sequence(:name) { |n| "Stack Title #{n}" }
    description "Stack description"
    user
  end
end
