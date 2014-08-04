include Warden::Test::Helpers
Warden.test_mode!
# Feature: Activity management
#   As an admin
#   I want to manage activities
#   So I can list activities
feature "Admin Activity management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list activities
  #   Given I am an admin
  #   When I try to navigate to activities page
  #   Then I can see the latest activities
  scenario "Admin can list system activities" do
    activity = FactoryGirl.create(:activity)

    page.find("[data-model=activity] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "activity")
    expect(page).to have_content activity.key
    expect(page).to have_content activity.owner.username
    expect(page).to have_content activity.trackable.name
  end

  # Scenario: Admin can show activity details
  #   Given I am an admin
  #   When I click to show an existing activity
  #   Then I see activity details
  scenario "admin can show activity details" do
    activity = FactoryGirl.create(:activity)
    page.find("[data-model=activity] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "activity")

    page.find(".activity_row[1] .show_member_link a").click
    expect(current_path).to eq rails_admin.show_path(model_name: "activity",
                                                     id: activity.id)

    expect(page).to have_content activity.key
    expect(page).to have_content activity.owner.username
    expect(page).to have_content activity.trackable.name
  end

  # Scenario: Admin cannot delete a activity
  #   Given I am an admin
  #   When I try to delete an activity
  #   Then I see an error message
  scenario "admin cannot delete an activity" do
    FactoryGirl.create(:activity)

    page.find("[data-model=activity] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "activity")
    expect do
      page.find(".activity_row[1] .delete_member_link a").click
    end.to raise_error
  end
end
