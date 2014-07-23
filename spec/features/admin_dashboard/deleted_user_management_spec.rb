include Warden::Test::Helpers
Warden.test_mode!
# Feature: Deleted User management
#   As an admin
#   I want to manage deleted users
#   So I can list, add, edit and restore deleted users
feature "Deleted User management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can edit a deleted user
  #   Given I am an admin
  #   When I try to edit an deleted user
  #   Then the user gets edited
  scenario "admin can edit a deleted user" do
    user = FactoryGirl.create(:user_deleted)

    visit rails_admin.edit_path(model_name: "deleted_user", id: user.id)
    fill_in "Username", with: "anotheruser"
    click_button "Save"

    user.reload
    expect(user.username).to eq "anotheruser"
  end

  # Scenario: Admin can restore a deleted user
  #   Given I am an admin
  #   When I try to restore a deleted user
  #   Then the user gets restore to active users list
  scenario "admin can restore a user" do
    user = FactoryGirl.create(:user_deleted)
    page.find("[data-model=deleted_user] a").click
    url = rails_admin.index_path(model_name: "deleted_user")
    expect(current_path).to eq url
    expect(page).to have_content user.username
    expect do
      page.find(".deleted_user_row[1] .restore_member_link a").click

    end.to change(DeletedUser, :count).by(-1)
  end
end
