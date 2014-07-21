# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reputation do
    sequence(:name){ |n| "Reputation #{n}"}
    sequence(:min_score){ |n| n * 10}
  end
end
