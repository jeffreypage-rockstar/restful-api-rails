include Warden::Test::Helpers
Warden.test_mode!
# Feature: Setting management
#   As an admin
#   I want to manage settings
#   So I can list and edit settings
feature "Admin Setting management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list system settings
  #   Given I am an admin
  #   When I try to navigate to settings page
  #   Then I can see the systems settings
  scenario "Admin can list system settings" do
    setting = FactoryGirl.create(:setting)

    page.find("[data-model=setting] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "setting")
    expect(page).to have_content setting.name
    expect(page).to have_content setting.value
    expect(page).to have_content setting.description
  end

  # Scenario: Admin can edit a setting
  #   Given I am an admin
  #   When I try to edit an existing setting
  #   Then the setting gets edited
  scenario "admin can edit an setting" do
    setting = FactoryGirl.create(:setting)

    expect(setting.value).to eql "enabled"
    visit rails_admin.edit_path(model_name: "setting", id: setting.id)
    select "disabled", from: "setting[value]"
    click_button "Save"

    setting.reload
    expect(setting.value).to eql "disabled"
  end

  # Scenario: Admin cannot delete a setting
  #   Given I am an admin
  #   When I try to delete an setting
  #   Then I see an error message
  scenario "admin cannot delete an setting" do
    FactoryGirl.create(:setting)

    page.find("[data-model=setting] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "setting")
    expect do
      page.find(".setting_row[1] .delete_member_link a").click
    end.to raise_error
  end
end
