# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stack_stats, class: "StackStats" do
    date Date.today
    stack
    subscriptions 10
    unsubscriptions 2
  end
end
