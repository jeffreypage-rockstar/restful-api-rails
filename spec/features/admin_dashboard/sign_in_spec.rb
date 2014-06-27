# Feature: Sign in
#   As an user
#   I want to sign in the admin dashboard
#   So I can manage the site
feature 'Admin Dashboard sign in', :devise do

  # Scenario: User cannot access to admin dashboard if not logged in
  #   Given I do not exist as a user
  #   When I try to access to the admin dashboard
  #   Then I am redirected to the sign in page
  scenario 'user cannot access to admin dashboard if not logged in' do
    visit rails_admin.dashboard_path
    expect(current_path).to eq new_admin_session_path
  end

  # Scenario: User cannot access to admin dashboard with invalid credentials
  #   Given I do not exist as a user
  #   When I try to access to the admin dashboard with invalid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot access to admin dashboard if not registered' do
    admin_signin('test', 'please123')
    expect(page).to have_content 'Invalid username or password.'
  end

  # Scenario: User cannot access to admin dashboard if is not an admin
  #   Given I exist as a user
  #   And I am not an admin
  #   When I sign in with valid credentials and an user role
  #   Then I am redirected outside of the admin dashboard
  scenario 'user cannot access to admin dashboard if is not an admin' do
    user = FactoryGirl.create(:user)
    admin_signin(user.username, user.password)
    expect(current_path).to eq new_admin_session_path
  end

  # Scenario: User can access to admin dashboard if is an admin
  #   Given I exist as a user
  #   And I am an admin
  #   When I sign in with valid credentials and an admin role
  #   Then I see a success message
  scenario 'user can access to admin dashboard if is an admin' do
    user = FactoryGirl.create(:admin)
    admin_signin(user.username, user.password)
    expect(current_path).to eq rails_admin.dashboard_path
  end
end
