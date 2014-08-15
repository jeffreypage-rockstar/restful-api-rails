require "rails_helper"

RSpec.describe CardImage, type: :model do
  describe ".create" do
    let(:attrs) do
      {
        caption: "My Card Image Caption",
        image_url: "http://imageurl.com/image.jpg",
        card: create(:card)
      }
    end

    it "creates a valid card image" do
      expect(CardImage.new(attrs)).to be_valid
    end

    it "requires a card_id" do
      image = CardImage.new(attrs.merge(card: nil))
      expect(image).to_not be_valid
    end

    it "requires an image_url" do
      image = CardImage.new(attrs.merge(image_url: ""))
      expect(image).to_not be_valid
    end

    it "requires a valid image_url" do
      image = CardImage.new(attrs.merge(image_url: "hyper.is/image.jpg"))
      expect(image).to_not be_valid
      expect(image.errors[:image_url].first).to match /is not a valid/
    end

    it "fixes image_url with a facebook invalid format" do
      url = "https:/hyper-inaka.com/E3C318D0-9948-4EBE-B187-7C4F39E3AEB0.jpg"
      image = CardImage.new(attrs.merge(image_url: url))
      expect(image).to be_valid
      expect(image.image_url).to match "https://hyper-inaka.com"
    end
  end

end
