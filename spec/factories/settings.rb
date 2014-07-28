# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :setting do
    key "MyString"
    value "MyString"
    description "MyText"
  end
end
