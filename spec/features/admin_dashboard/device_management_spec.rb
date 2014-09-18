include Warden::Test::Helpers
Warden.test_mode!
# Feature: Device management
#   As an admin
#   I want to manage devices
#   So I can list add, edit, and delete devices
feature "Admin Device management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list the devices
  #   Given I am an admin
  #   When I try access the devices page
  #   Then I can see the recent devices list
  scenario "admin can list devices" do
    device = FactoryGirl.create(:device)

    page.find("[data-model=device] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "device")
    expect(page).to have_content device.user.username
    expect(page).to have_content device.device_type
  end

  # Scenario: Admin can edit an Device
  #   Given I am an admin
  #   When I try to edit an existing device
  #   Then the device gets edited
  scenario "admin can edit an Device" do
    device = FactoryGirl.create(:device)
    new_user = FactoryGirl.create(:user)

    visit rails_admin.edit_path(model_name: "device", id: device.id)
    select new_user.username, from: "device[user_id]"
    click_button "Save"

    device.reload
    expect(device.user_id).to eq new_user.id
  end

  # Scenario: Admin can delete an device
  #   Given I am an admin
  #   When I try to delete an device
  #   Then an device gets deleted
  scenario "admin can delete an device" do
    FactoryGirl.create(:device)

    page.find("[data-model=device] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "device")
    expect do
      page.find(".device_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Device, :count).by(-1)
  end
end
