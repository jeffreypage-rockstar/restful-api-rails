# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card_image do
    original_image_url "http://placehold.it/480x320"
    caption "a image caption"
    image_processing true
    card
  end
end
