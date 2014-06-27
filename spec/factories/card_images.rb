# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card_image do
    image_url 'http://placehold.it/480x320'
    caption 'a image caption'
    card
  end
end
