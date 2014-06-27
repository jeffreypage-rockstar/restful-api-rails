include Warden::Test::Helpers
Warden.test_mode!
# Feature: Admin user management
#   As an user
#   I want to manage admin users
#   So I can list add, edit, and delete admin users
feature 'Admin user management', :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create an admin user
  #   Given I am an admin
  #   When I try to create an admin user
  #   Then an admin user gets added to the system
  scenario 'admin can create an admin user' do
    new_user = FactoryGirl.attributes_for(:admin)
    page.find('[data-model=admin] a').click
    expect(current_path).to eq rails_admin.index_path(model_name: 'admin')
    expect do
      visit rails_admin.new_path(model_name: 'admin')
      fill_in 'Email', with: new_user[:email]
      fill_in 'Password', with: new_user[:password]
      fill_in 'Password confirmation', with: new_user[:password]
      fill_in 'Username', with: new_user[:username]
      click_button 'Save'
    end.to change(Admin, :count).by(1)
    expect(current_path).to eq rails_admin.index_path(model_name: 'admin')
    expect(page).to have_content new_user[:username]
    expect(page).to have_content new_user[:email]
  end

  # Scenario: Admin can edit an admin user
  #   Given I am an admin
  #   When I try to edit an existing admin user
  #   Then the admin user gets edited
  scenario 'admin can edit a user' do
    user = FactoryGirl.create(:admin)

    visit rails_admin.edit_path(model_name: 'admin', id: user.id)
    fill_in 'Username', with: 'anotheruser'
    click_button 'Save'

    user.reload
    expect(user.username).to eq 'anotheruser'
  end

  # Scenario: Admin can delete an admin user
  #   Given I am an admin
  #   When I try to delete an existing admin user
  #   Then the admin user gets deleted from the system
  scenario 'admin can delete a user' do
    FactoryGirl.create(:admin)
    page.find('[data-model=admin] a').click
    expect(current_path).to eq rails_admin.index_path(model_name: 'admin')

    expect do
      page.find('.admin_row[1] .delete_member_link a').click
      click_button "Yes, I'm sure"
    end.to change(Admin, :count).by(-1)
  end
end
