require "rails_helper"

RSpec.describe Notifier::CardUpVote, type: :worker do
  let(:worker) { Notifier::CardUpVote.new }

  it "performs generating notifications for card owner" do
    expect(Notifier::CardUpVote).to receive(:perform_async).once.
                                    and_return("0001")
    card = create(:card)
    other_user = create(:user)

    PublicActivity.with_tracking do
      card.vote_by!(other_user)
      act = card.activities.where(key: "card.up_vote").last
      notifications = worker.perform(act.id)
      expect(act.reload).to be_notified
      expect(notifications.size).to eql 1
      notifications.each { |n| expect(n).to be_persisted }
      notifications.each { |n| expect(n).to be_sent }
      expect(card.user.notifications.unread.count).to eql 1
    end
  end
end
