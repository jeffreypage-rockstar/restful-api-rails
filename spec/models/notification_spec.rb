require "rails_helper"

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }

  describe ".create" do
    let(:attrs) { attributes_for(:notification).merge(user_id: user.id) }

    it "creates a valid notification" do
      expect(Notification.new(attrs)).to be_valid
    end

    it "requires a user" do
      notification = Notification.new(attrs.merge(user: nil))
      expect(notification).to_not be_valid
    end

    it "requires a subject" do
      notification = Notification.new(attrs.merge(subject: nil))
      expect(notification).to_not be_valid
    end

    it "requires an action" do
      notification = Notification.new(attrs.merge(action: ""))
      expect(notification).to_not be_valid
    end
  end

  describe "#mask_as_read!" do

    it "updates the notification as read" do
      notification = create(:notification)
      expect(notification).to_not be_read
      expect(notification.mask_as_read!).to eql true
      expect(notification).to be_read
    end
  end

  describe ".mark_all_as_read" do
    it "does not mark as read a not sent notification" do
      notification = create(:notification, user: user)
      expect(user.notifications.unread.count).to eql 1
      Notification.mark_all_as_read(user.id, notification)
      expect(user.notifications.unread.count).to eql 1
    end

    it "marks all user sent notifications as read" do
      notifications = (1..4).map { create(:sent_notification, user: user) }
      travel_to 1.minute.from_now do
        create(:notification, user: user, sent_at: Time.current)
      end
      expect(user.notifications.unread.count).to eql 5
      Notification.mark_all_as_read(user.id, notifications.last)
      expect(user.notifications.unread.count).to eql 1
    end
  end

  describe ".mark_all_as_seen" do
    it "does not mark as seen a not sent notification" do
      notification = create(:notification, user: user)
      expect(user.notifications.unseen.count).to eql 1
      Notification.mark_all_as_seen(user.id, notification)
      expect(user.notifications.unseen.count).to eql 1
    end

    it "marks all user notifications as seen" do
      notifications = (1..4).map { create(:sent_notification, user: user) }
      travel_to 1.minute.from_now do
        create(:notification, user: user, sent_at: Time.current)
      end
      expect(user.notifications.unseen.count).to eql 5
      Notification.mark_all_as_seen(user.id, notifications.last)
      expect(user.notifications.unseen.count).to eql 1
    end
  end

  describe "#add_sender" do
    it "adds a user as a notification sender" do
      notification = build(:notification)
      notification.add_sender(user)
      notification.add_sender(user)
      notification.save
      notification.reload
      expect(notification.senders_count).to eql 1
      expect(notification.senders[user.username]).to eql user.id
    end

    it "does not add a nil user" do
      notification = build(:notification)
      notification.add_sender(nil)
      expect(notification.save).to be_truthy
    end
  end

  describe "#similar_notifications" do
    it "query db for similar notifications" do
      old_notification = create(:notification)
      create(:notification) # another subject
      notification = create(:notification, subject: old_notification.subject)
      similar = notification.similar_notifications
      expect(similar.size).to eql 1
      expect(similar.first.id).to eql old_notification.id
    end
  end

  describe "#require_push_notification?" do
    it "returns true for create and reply actions" do
      notification = build(:notification, action: "card.create")
      expect(notification.require_push_notification?).to be_truthy

      notification = build(:notification, action: "comment.create")
      expect(notification.require_push_notification?).to be_truthy

      notification = build(:notification, action: "comment.reply")
      expect(notification.require_push_notification?).to be_truthy
    end

    it "returns true for first up_vote" do
      notification = build(:notification, action: "card.up_vote")
      expect(notification.require_push_notification?).to be_truthy
    end

    it "returns true for up_votes in the interval" do
      notification = create(:notification, action: "card.up_vote")
      allow(notification.subject.votes).to receive(:count).and_return(
                                             Notification::PUSH_VOTES_INTERVAL
                                           )
      expect(notification.require_push_notification?).to be_truthy
    end

    it "return false for a second up_votes" do
      notification = create(:notification, action: "card.up_vote")
      create(:notification, action: "card.up_vote",
                            subject: notification.subject)
      allow(notification.subject.votes).to receive(:count).and_return(2)
      expect(notification.require_push_notification?).to be_falsey
    end
  end

  describe "#sent!" do
    it "marks the notification as sent" do
      notification = build(:notification)
      notification.sent!
      expect(notification).to be_sent
    end

    it "resets the notification state to unseen and unread" do
      notification = create(:notification, seen_at: Time.now, read_at: Time.now)
      expect(notification).to be_seen
      expect(notification).to be_read
      notification.sent!
      expect(notification).to_not be_seen
      expect(notification).to_not be_read
    end
  end

  describe "#caption" do
    let(:stack) { build :stack, name: "stack_name" }
    let(:card) { build :card, name: "card_name", stack: stack }
    let(:sender_user) { create :user }
    let(:one_sender) { { "user_name" => sender_user.id } }
    let(:three_senders) do
      { "user_name_1" => 1, "user_name_2" => 2,
                           "user_name_3" => 3 }
    end
    let(:four_senders) do
      { "user_name_1" => 1, "user_name_2" => 2,
                           "user_name_3" => 3, "user_name_4" => 4 }
    end
    subject(:caption) { notification.caption }

    describe "card.create" do
      let(:notification) do
        build :card_create_notification, senders: senders,
                                         subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it { is_expected.to eql "user_name posted in #stack_name" }
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "posted in #stack_name"
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it { is_expected.to eql "4 posts were made in #stack_name" }
      end
    end

    describe "card.up_vote" do
      let(:notification) do
        build :card_up_vote_notification, senders: senders,
                                          subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it { is_expected.to eql "user_name upvoted your post \"card_name\"" }
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "upvoted your post \"card_name\""
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it { is_expected.to eql "4 people upvoted your post \"card_name\"" }
      end
    end

    describe "subscription.create" do
      let(:notification) do
        build :subscription_create_notification, senders: senders,
                                                 subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it { is_expected.to eql "user_name started following #card_name" }
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "started following #card_name"
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it { is_expected.to eql "4 people have started following #card_name" }
      end
    end

    describe "comment.create" do
      let(:notification) do
        build :comment_create_notification, senders: senders,
                                            subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it do
          is_expected.to eql "user_name commented on your "\
        "post \"card_name\""
        end
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "commented on your post \"card_name\""
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it do
          is_expected.to eql "4 people commented on your post "\
        "\"card_name\""
        end
      end
    end

    describe "comment.upvote" do
      let(:notification) do
        build :comment_up_vote_notification, senders: senders,
                                             subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it { is_expected.to eql "user_name upvoted your comment" }
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "upvoted your comment"
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it { is_expected.to eql "4 people upvoted your comment" }
      end
    end

    describe "comment.reply" do
      let(:notification) do
        build :comment_reply_notification, senders: senders,
                                           subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it { is_expected.to eql "user_name replied to your comment" }
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "replied to your comment"
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it { is_expected.to eql "4 people replied to your comment" }
      end
    end

    describe "comment.mention" do
      let(:notification) do
        build :comment_mention_notification, senders: senders,
                                             subject: card
      end

      context "single sender" do
        let(:senders) { one_sender }
        it { is_expected.to eql "user_name tagged you in a comment" }
      end

      context "three senders" do
        let(:senders) { three_senders }
        it do
          is_expected.to eql "user_name_1, user_name_2 and user_name_3 "\
        "tagged you in a comment"
        end
      end

      context "four senders" do
        let(:senders) { four_senders }
        it { is_expected.to eql "4 people tagged you in a comment" }
      end
    end
  end

  describe "#image_url" do
    [
      :card_create_notification,
      :subscription_create_notification
    ].each do |notification_type|
      it "returns notification image_url for only one sender" \
             " in #{notification_type.to_s.humanize}" do
        card_image = create :card_image
        card = card_image.card
        senders = { user.username => user.id }
        notification = create(notification_type, senders: senders,
                                                 subject: card)
        expect(notification.image_url).to eql card_image.image_url
      end
    end

    [
      :card_up_vote_notification,
      :comment_create_notification,
      :comment_reply_notification,
      :comment_mention_notification,
      :comment_up_vote_notification
    ].each do |notification_type|
      it "returns user's avatar for only one sender" \
             " in #{notification_type.to_s.humanize}" do
        senders = { user.username => user.id }
        notification = create(notification_type, senders: senders)
        expect(notification.image_url).to eql user.avatar_url
      end
    end

    it "returns notification image_url por more than one sender" do
      card_image = create :card_image
      card = card_image.card
      senders = { "john" => 1, "peter" => 2 }
      notification = create(:notification, senders: senders, subject: card)
      expect(notification.image_url).to eql card_image.image_url
    end
  end
end
