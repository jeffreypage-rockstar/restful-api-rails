# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    user
    subject { build(:card) }
    action "card.up_vote"
  end
end
