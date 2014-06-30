# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature "Sign in", :devise do

  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario "user cannot sign in if not registered" do
    signin("testusername", "please123")
    expect(page).to have_content "Invalid username or password."
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario "user can sign in with valid credentials" do
    user = FactoryGirl.create(:user)
    signin(user.username, user.password)
    expect(page).to have_content "Signed in successfully."
  end

  # Scenario: User cannot sign in with wrong username
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong username
  #   Then I see an invalid username message
  scenario "user cannot sign in with wrong username" do
    user = FactoryGirl.create(:user)
    signin("invalidusername", user.password)
    expect(page).to have_content "Invalid username or password."
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario "user cannot sign in with wrong password" do
    user = FactoryGirl.create(:user)
    signin(user.username, "invalidpass")
    expect(page).to have_content "Invalid username or password."
  end

end
