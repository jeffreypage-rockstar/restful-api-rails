# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification, aliases: [:card_up_vote_notification] do
    user
    subject { build(:card) }
    action "card.up_vote"

    factory :sent_notification do
      sent_at Time.current
    end

    factory :card_create_notification do
      action "card.create"
    end

    factory :subscription_create_notification do
      action "subscription.create"
      subject { build(:subscription) }
    end

    factory :comment_create_notification do
      action "comment.create"
      subject { build(:comment) }
    end

    factory :comment_reply_notification do
      action "comment.reply"
      subject { build(:comment) }
    end

    factory :comment_mention_notification do
      action "comment.mention"
      subject { build(:comment) }
    end

    factory :comment_up_vote_notification do
      action "comment.up_vote"
      subject { build(:comment) }
    end
  end
end
