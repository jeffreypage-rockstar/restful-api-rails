# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification_sender, aliases: [:sender]  do
    sequence(:user_id) { |n| "fd2c6384-d54b-42c4-8efc-813a994c61#{n}c" }
    sequence(:username) { |n| "user_name_#{n}" }
    notification
  end
end
