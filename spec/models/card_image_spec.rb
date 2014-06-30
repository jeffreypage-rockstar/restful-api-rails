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
  end

end
