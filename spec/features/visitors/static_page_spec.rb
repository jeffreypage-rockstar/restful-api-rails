# Feature: Static page
#   As a visitor
#   I want to visit a public static page
#   So I can see static details and images
feature "Static page" do
  before do
    @page = create(:page)
  end

  # Scenario: Visit a static page
  #   Given I am a visitor
  #   When I visit a static page
  #   Then I see the static page details
  scenario "visit a static page" do
    visit static_path(@page)
    expect(page).to have_content @page.title
  end

  # Scenario: Visit an invalid static page
  #   Given I am a visitor
  #   When I visit an invalid static page url
  #   Then I see the 404 error page
  scenario "visit an invalid static page" do
    expect do
      visit static_path(id: "invalid")
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

end
