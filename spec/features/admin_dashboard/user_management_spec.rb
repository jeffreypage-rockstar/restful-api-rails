include Warden::Test::Helpers
Warden.test_mode!
# Feature: User management
#   As an user
#   I want to manage users
#   So I can list add, edit, and delete users
feature "User management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can edit a user
  #   Given I am an admin
  #   When I try to edit an existing user
  #   Then the user gets edited
  scenario "admin can edit a user" do
    user = FactoryGirl.create(:user)

    visit rails_admin.edit_path(model_name: "user", id: user.id)
    fill_in "Username", with: "anotheruser"
    click_button "Save"

    user.reload
    expect(user.username).to eq "anotheruser"
  end

  # Scenario: Admin can delete a user
  #   Given I am an admin
  #   When I try to delete an existing user
  #   Then the user gets deleted from the system
  scenario "admin can delete a user" do
    FactoryGirl.create(:user)
    page.find("[data-model=user] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "user")

    expect do
      page.find(".user_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(User, :count).by(-1)
  end
end
