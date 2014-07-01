# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :vote do
    flag true
    user
    votable { build(:card) }
  end
end
