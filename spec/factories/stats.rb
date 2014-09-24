# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stat, class: "Stats" do
    date "2014-09-24"
    users_count 1
  end
end
