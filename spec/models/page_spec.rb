require "rails_helper"

RSpec.describe Page, type: :model do
  describe ".create" do
    let(:attrs) do
      attributes_for(:page)
    end

    it "creates a valid page" do
      expect(Page.new(attrs)).to be_valid
    end

    it "requires a title" do
      page = Page.new(attrs.merge(title: ""))
      expect(page).to_not be_valid
    end

    it "generates a slug" do
      page = Page.new(attrs.merge(slug: ""))
      expect(page).to be_valid
      expect(page.slug).to match "my-page"
    end

    it "requires a unique slug" do
      page = create(:page)
      other_page = Page.new(attrs.merge(slug: page.slug))
      expect(other_page).to_not be_valid
      expect(other_page.errors[:slug].first).to match "taken"
    end
  end
end
