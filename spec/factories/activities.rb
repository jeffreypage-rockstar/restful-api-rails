# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity do
    key "card.create"
    owner { build(:user) }
    trackable { build(:card) }
  end
end
