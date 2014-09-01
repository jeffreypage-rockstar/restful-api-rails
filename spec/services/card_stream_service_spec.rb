require "rails_helper"

RSpec.describe CardStreamService, type: :service do
  let(:scroll_id)do
    "cXVlcnlUaGVuRmV0Y2g7NTsyMTY6djA1VHdad29SNUtJdVVPZ1BUakYxZ"\
    "zsyMTc6djA1VHdad29SNUtJdVVPZ1BUakYxZzsyMTg6djA1VHdad29SNUtJdVVPZ1BUakYxZ"\
    "zsyMTk6djA1VHdad29SNUtJdVVPZ1BUakYxZzsyMjA6djA1VHdad29SNUtJdVVPZ1BUakYxZ"\
    "zswOw=="
  end

  before do
    [
      "e0a70962-b80d-490f-8807-f0cdc4b027ed",
      "196dac35-299b-4a41-889c-d31fedc9044b",
      "1124aff9-9afe-4c4b-9d06-205eaead1932",
      "c71d6671-50a1-4218-9dd9-2b4307b75643"
    ].each { |id| create(:card, id: id) }
  end

  it "loads cards sorted by age" do
    VCR.use_cassette("card_stream_newest") do
      stream = CardStreamService.new(order_by: "newest")
      stream.execute
      expect(stream.cards.size).to eql(4)
      expect(stream.total_entries).to eql(4)
      expect(stream.scroll_id).to_not be_blank
    end
  end

  it "loads cards sorted by popularity" do
    VCR.use_cassette("card_stream_popularity") do
      stream = CardStreamService.new(order_by: "popularity")
      stream.execute
      expect(stream.cards.size).to eql(4)
      expect(stream.total_entries).to eql(4)
      expect(stream.scroll_id).to_not be_blank
    end
  end

  it "loads cards from a scroll" do
    VCR.use_cassette("card_stream_scroll") do
      stream = CardStreamService.new(scroll_id: scroll_id)
      stream.execute
      expect(stream.cards.size).to eql(0)
      expect(stream.total_entries).to eql(4)
      expect(stream.scroll_id).to_not be_blank
    end
  end

  it "fails when scroll id is expired" do
    VCR.use_cassette("card_stream_expired") do
      expect do
        stream = CardStreamService.new(scroll_id: scroll_id)
        stream.execute
      end.to raise_error(ArgumentError)
    end
  end
end
