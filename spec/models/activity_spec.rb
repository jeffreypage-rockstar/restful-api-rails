require "rails_helper"

RSpec.describe PublicActivity::Activity, type: :model do

  describe ".create_activity" do
  
    it "trigger a notifier for a card create" do
      expect(Notifier::CardCreate).to receive(:perform_async).once
      PublicActivity.with_tracking do
        card = create(:card)
        act = card.activities.last
        expect(act).to_not be_notified
      end
    end
  end
end
