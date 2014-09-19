# Feature: Card page
#   As a visitor
#   I want to visit a public card page
#   So I can see card details and images
feature "Card page" do
  before do
    @card = create(:card)
    (1..2).each { create(:card_image, card: @card) }
    (1..2).each { create(:comment, card: @card) }
  end

  # Scenario: Visit a card page
  #   Given I am a visitor
  #   When I visit a card page
  #   Then I see the card details
  #     And the card images with captions
  scenario "visit a card page" do
    visit card_path(@card)
    expect(page).to have_content @card.name
    expect(page).to have_content @card.user.username
    @card.images.each do |image|
      expect(page).to have_xpath("//img[@src='#{image.image_url}']")
      expect(page).to have_content image.caption
    end

    @card.comments.each do |comment|
      expect(page).to have_content comment.body
    end

  end

end
