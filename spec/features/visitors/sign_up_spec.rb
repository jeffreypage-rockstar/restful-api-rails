# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature "Sign Up", :devise do

  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario "visitor can sign up with email address, username and password" do
    sign_up_with("test@example.com", "testuser", "please123", "please123")
    msg = "Welcome! You have signed up successfully."
    expect(page).to have_content msg
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario "visitor cannot sign up with invalid email address" do
    sign_up_with("bogus", "bogusname", "please123", "please123")
    expect(page).to have_content "Emailis invalid"
  end

  # Scenario: Visitor cannot sign up with invalid username
  #   Given I am not signed in
  #   When I sign up with an invalid username
  #   Then I see an invalid username message
  scenario "visitor cannot sign up with invalid username" do
    sign_up_with("test@example.com", "bogusname??", "please123", "please123")
    expect(page).to have_content "Usernameis invalid"
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  scenario "visitor cannot sign up without password" do
    sign_up_with("test@example.com", "testuser", "", "")
    expect(page).to have_content "Passwordcan't be blank"
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario "visitor cannot sign up with a short password" do
    sign_up_with("test@example.com", "testuser", "short", "short")
    expect(page).to have_content "Passwordis too short"
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  scenario "visitor cannot sign up without password confirmation" do
    sign_up_with("test@example.com", "testuser", "please123", "")
    expect(page).to have_content "Password confirmationdoesn't match"
  end

  # Scenario: Visitor cannot sign up with mismatched password and confirmation
  #   Given I am not signed in
  #   When I sign up with a mismatched password confirmation
  #   Then I should see a mismatched password message
  scenario "visitor cannot sign up with mismatched password and confirmation" do
    sign_up_with("test@example.com", "testuser", "please123", "mismatch")
    expect(page).to have_content "Password confirmationdoesn't match"
  end

end
