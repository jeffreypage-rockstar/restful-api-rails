# Feature: Password Reset
#   As a user
#   I want to reset my password
#   So I can sign in with the new password
feature 'Confirm email', :devise do
  let(:user){ create(:user) }

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  # Scenario: User submits his email to reset the password
  #   Given I have a forgot my password
  #   When I visit the reset password page
  #     And submit my e-mail
  #   Then I receives an email with a reset password token
  scenario 'User submits his email to reset the password' do
    reset_password
    expect(page).to have_content 'You will receive an email with instructions'\
                                 ' on how to reset your password in a few'\
                                 ' minutes.'
    
    expect(reset_password_token).to_not be_blank
  end
  
  # Scenario: User with a valid token enter a new password
  #   Given I have a reset password token
  #   When I visit the edit password page
  #     And submit a new password
  #   Then I can sign in using the new password
  scenario 'User with a valid token enter a new password' do
    reset_password
    visit edit_user_password_path(:reset_password_token => reset_password_token)
    new_password = "new.pass.123"
    fill_in 'New password', with: new_password
    fill_in 'Confirm new password', with: new_password
    click_button 'Change my Password'
    expect(page).to have_content "Your password was changed successfully."
  end
  
  private
  
  def reset_password
    visit new_user_password_path
    fill_in 'Email', with: user.email
    click_button 'Reset Password'
  end
  
  def reset_password_token
    email_body = ActionMailer::Base.deliveries.last.body.to_s
    if email_body =~ /\?reset_password_token\=(\w*)/ then $1 else "" end
  end
end
