include Warden::Test::Helpers
Warden.test_mode!
# Feature: Reputations management
#   As an admin
#   I want to manage reputations
#   So I can list add, edit, and delete reputations
feature "Admin Reputation management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create a new reputation
  #   Given I am an admin
  #   When I try to create an reputation
  #   Then a reputation gets added to the system
  scenario "admin can create an reputation" do
    new_reputation = FactoryGirl.attributes_for(:reputation)

    page.find("[data-model=reputation] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "reputation")
    expect do
      visit rails_admin.new_path(model_name: "reputation")
      fill_in "Name", with: new_reputation[:name]
      fill_in "Min score", with: new_reputation[:min_score]
      click_button "Save"
    end.to change(Reputation, :count).by(1)
    expect(current_path).to eq rails_admin.index_path(model_name: "reputation")
    expect(page).to have_content new_reputation[:name]
    expect(page).to have_content new_reputation[:min_score]
  end

  # Scenario: Admin can edit a reputation
  #   Given I am an admin
  #   When I try to edit an existing reputation
  #   Then the reputation gets edited
  scenario "admin can edit a reputation" do
    reputation = FactoryGirl.create(:reputation)

    visit rails_admin.edit_path(model_name: "reputation", id: reputation.id)
    fill_in "Name", with: "anothername"
    fill_in "Min score", with: -1
    click_button "Save"

    reputation.reload
    expect(reputation.name).to eq "anothername"
    expect(reputation.min_score).to eq -1
  end

  # Scenario: Admin can delete an reputation
  #   Given I am an admin
  #   When I try to delete an reputation
  #   Then an reputation gets deleted
  scenario "admin can delete an reputation" do
    FactoryGirl.create(:reputation)

    page.find("[data-model=reputation] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "reputation")
    expect do
      page.find(".reputation_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Reputation, :count).by(-1)
  end
end
