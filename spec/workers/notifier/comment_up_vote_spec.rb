require "rails_helper"

RSpec.describe Notifier::CommentUpVote, type: :worker do
  let(:worker) { Notifier::CommentUpVote.new }

  it "performs generating notifications for comment owner" do
    expect(Notifier::CommentUpVote).to receive(:perform_async).once.
                                    and_return("0001")
    comment = create(:comment)
    other_user = create(:user)

    PublicActivity.with_tracking do
      comment.vote_by!(other_user)
      act = comment.activities.where(key: "comment.up_vote").last
      worker.perform(act.id)
      notifications = Notification.where(action: "comment.up_vote").all
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 1
      notifications.each { |n| expect(n).to be_persisted }
      notifications.each { |n| expect(n).to be_sent }
      expect(comment.user.notifications.unread.count).to eql 1
    end
  end
end
