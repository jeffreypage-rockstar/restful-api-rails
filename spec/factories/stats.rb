# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stats, class: "Stats" do
    date "2014-09-24"
    users 3
    deleted_users 1
  end
end
