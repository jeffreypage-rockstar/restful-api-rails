require "carrierwave/test/matchers"

describe CardImageUploader do
  include CarrierWave::Test::Matchers
  let(:card_image) { create(:card_image) }
  let(:path_to_file) { File.expand_path("../../fixtures/image.jpg",  __FILE__) }

  before do
    CardImageUploader.enable_processing = true
    @uploader = CardImageUploader.new(card_image, :image)
    @uploader.store!(File.open(path_to_file))
  end

  after do
    CardImageUploader.enable_processing = false
    @uploader.remove!
  end

  it "should generate a thumbnail with maximum 320px width" do
    expect(@uploader.thumbnail).to have_dimensions(320, 320)
  end

  it "should process the image to 640px width" do
    expect(@uploader).to have_dimensions(640, 640)
  end
end
