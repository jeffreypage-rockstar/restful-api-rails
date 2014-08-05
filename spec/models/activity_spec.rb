require "rails_helper"

RSpec.describe Activity, type: :model do

  describe ".create_activity" do

    it "triggers a Notifier call after save" do
      expect(Notifier).to receive(:notify_async).with(/\w/, "card.create")
      create(:activity)
    end

    it "triggers a notifier for a card create" do
      expect(Notifier::CardCreate).to receive(:perform_async).once.
                                      and_return("00001")
      PublicActivity.with_tracking do
        card = create(:card)
        act = card.activities.last
        expect(act).to_not be_notified
      end
    end
  end
end
