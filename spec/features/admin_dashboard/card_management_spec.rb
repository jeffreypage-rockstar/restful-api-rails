include Warden::Test::Helpers
Warden.test_mode!
# Feature: Card management
#   As an admin
#   I want to manage cards
#   So I can list add, edit, and delete cards
feature "Admin Card management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create a new card
  #   Given I am an admin
  #   When I try to create an card
  #   Then an card gets added to the system
  scenario "admin can create an card" do
    new_user = FactoryGirl.create(:user)
    new_stack = FactoryGirl.create(:stack)
    new_card = FactoryGirl.attributes_for(:card)

    page.find("[data-model=card] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "card")
    expect do
      visit rails_admin.new_path(model_name: "card")
      fill_in "Name", with: new_card[:name]
      fill_in "Description", with: new_card[:description]
      select new_card[:source], from: "card[source]"
      select new_stack.name, from: "card[stack_id]"
      select new_user.username, from: "card[user_id]"
      click_button "Save"
    end.to change(Card, :count).by(1)
    expect(current_path).to eq rails_admin.index_path(model_name: "card")
    expect(page).to have_content new_card[:name]
    expect(page).to have_content new_stack[:name]
    expect(page).to have_content new_user[:username]
  end

  # Scenario: Admin can edit an Card
  #   Given I am an admin
  #   When I try to edit an existing card
  #   Then the card gets edited
  scenario "admin can edit an Card" do
    card = FactoryGirl.create(:card)

    visit rails_admin.edit_path(model_name: "card", id: card.id)
    fill_in "Name", with: "anothername"
    fill_in "Description", with: "anotherdescription"
    click_button "Save"

    card.reload
    expect(card.name).to eq "anothername"
    expect(card.description).to eq "anotherdescription"
  end

  # Scenario: Admin can delete an card
  #   Given I am an admin
  #   When I try to delete an card
  #   Then an card gets deleted
  scenario "admin can delete an card" do
    FactoryGirl.create(:card)

    page.find("[data-model=card] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "card")
    expect do
      page.find(".card_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Card, :count).by(-1)
  end
end
