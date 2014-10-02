include Warden::Test::Helpers
Warden.test_mode!
# Feature: Page management
#   As an admin
#   I want to manage pages
#   So I can list add, edit, and delete pages
feature "Admin Page management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create a new page
  #   Given I am an admin
  #   When I try to create an page
  #   Then an page gets added to the system
  scenario "admin can create an page" do
    new_page = FactoryGirl.build(:page)

    page.find("[data-model=page] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "page")
    expect do
      visit rails_admin.new_path(model_name: "page")
      fill_in "Title", with: new_page.title
      fill_in "Content", with: new_page.content
      click_button "Save"
    end.to change(Page, :count).by(1)
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "page")
    expect(page).to have_content new_page[:title]
    expect(page).to have_content new_page[:slug]
  end

  # Scenario: Admin can edit an Page
  #   Given I am an admin
  #   When I try to edit an existing page
  #   Then the page gets edited
  scenario "admin can edit an Page" do
    a_page = FactoryGirl.create(:page)
    visit rails_admin.
          edit_path(model_name: "page", id: a_page.id)
    fill_in "Title", with: "New page title"
    click_button "Save"

    a_page.reload
    expect(a_page.title).to eq "New page title"
  end

  # Scenario: Admin can delete an page
  #   Given I am an admin
  #   When I try to delete an page
  #   Then an page gets deleted
  scenario "admin can delete an page" do
    FactoryGirl.create(:page)

    page.find("[data-model=page] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "page")
    expect do
      page.find(".page_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Page, :count).by(-1)
  end

end
