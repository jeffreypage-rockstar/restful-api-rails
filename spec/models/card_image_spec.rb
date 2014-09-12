require "rails_helper"

RSpec.describe CardImage, type: :model do
  describe ".create" do
    let(:attrs) do
      {
        caption: "My Card Image Caption",
        original_image_url: "http://imageurl.com/image.jpg",
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
      image = CardImage.new(attrs.merge(original_image_url: ""))
      expect(image).to_not be_valid
    end

    it "requires a valid image_url" do
      image = CardImage.new(
        attrs.merge(original_image_url: "hyper.is/image.jpg")
      )
      expect(image).to_not be_valid
      expect(image.errors[:original_image_url].first).to match /is not a valid/
    end

    it "fixes image_url with a facebook invalid format" do
      url = "https:/hyper-inaka.com/E3C318D0-9948-4EBE-B187-7C4F39E3AEB0.jpg"
      image = CardImage.new(attrs.merge(original_image_url: url))
      expect(image).to be_valid
      expect(image.image_url).to match "https://hyper-inaka.com"
    end

    it "triggers a ImageProcessWorker to generate the thumbnail" do
      image = build(:card_image, image_processing: false)
      expect(ImageProcessWorker).to receive(:perform_async).
                                    with(/\w/, image.original_image_url).once
      image.save
      expect(image.reload.image_processing).to be_truthy
    end
  end

  describe "#thumbnail_url" do
    let(:card_image) { build(:card_image) }
    let(:file_path) { File.expand_path("../../fixtures/image.jpg",  __FILE__) }

    it "generates a valid thumbnail_url" do
      card_image.image = File.open(file_path)
      expect(card_image.save).to be_truthy
      expected_image_url = "/uploads/#{card_image.id}/image.jpg"
      expected_thumbnail_url = "/uploads/#{card_image.id}/thumbnail_image.jpg"
      expect(card_image.image_url).to eql expected_image_url
      expect(card_image.thumbnail_url).to eql expected_thumbnail_url
    end
  end

end
