FactoryGirl.define do
  factory :device do
    user
    device_type "iphone"

    factory :device_with_arn do
      last_sign_in_at 1.day.ago
      push_token "avalidpushtoken"
      sns_arn "<<app_arn>>/8fb4f9e0-298a-38a3-9cf2-47614468d37e"
    end
  end
end
