include Warden::Test::Helpers
Warden.test_mode!
# Feature: Flag management
#   As an admin
#   I want to manage flags
#   So I can list add, edit, and delete flags
feature "Admin Flag management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list the flags
  #   Given I am an admin
  #   When I try access the flags page
  #   Then I can see the recent flags list
  scenario "admin can list flags" do
    flag = FactoryGirl.create(:flag)

    page.find("[data-model=flag] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "flag")
    expect(page).to have_content flag.user.username
    expect(page).to have_content flag.flaggable.name
  end

  # Scenario: Admin can edit an Flag
  #   Given I am an admin
  #   When I try to edit an existing flag
  #   Then the flag gets edited
  scenario "admin can edit an Flag" do
    flag = FactoryGirl.create(:flag)
    new_user = FactoryGirl.create(:user)

    visit rails_admin.edit_path(model_name: "flag", id: flag.id)
    select new_user.username, from: "flag[user_id]"
    click_button "Save"

    flag.reload
    expect(flag.user_id).to eq new_user.id
  end

  # Scenario: Admin can delete an flag
  #   Given I am an admin
  #   When I try to delete an flag
  #   Then an flag gets deleted
  scenario "admin can delete an flag" do
    FactoryGirl.create(:flag)

    page.find("[data-model=flag] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "flag")
    expect do
      page.find(".flag_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Flag, :count).by(-1)
  end
end
