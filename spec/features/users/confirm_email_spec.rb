# Feature: Confirm email
#   As a user
#   I want to confirm my email
#   So I can create stacks and cards
feature 'Confirm email', :devise do

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  # Scenario: User cannot confirm an email with an invalid token
  #   Given I do not have a confirmation token
  #   When I visit email confirmation page
  #   Then I see the resend confirmation form
  scenario 'user cannot confirm an email with an invalid token' do
    visit user_confirmation_path(confirmation_token: 'token')
    expect(page).to have_content 'Resend confirmation'
  end

  # Scenario: User can confirm his email with a valid token
  #   Given I have a valid confirmation token
  #   When I visit the email confirmation page
  #   Then I am redirected to sign in page with the confirmed message
  scenario 'user can confirm his email with a valid token' do
    create(:user, confirmed_at: nil)
    email_body = ActionMailer::Base.deliveries.last.body.to_s
    token = if email_body =~ /\?confirmation_token=(.*)\"/ then $1 else '' end
    visit user_confirmation_path(confirmation_token: token)
    expect(page).to have_content 'Your account was successfully confirmed.'
  end

  # Scenario: User can submit his email to receive a new confirmation token
  #   Given I do not have a valid confirmation token
  #   When I visit resend email confirmation page
  #     And submit my account email
  #   Then I receives a new message with a new token
  scenario 'user can submit his email to receive a new confirmation token' do
    user = create(:user, confirmed_at: nil)
    visit new_user_confirmation_path
    fill_in 'Email', with: user.email
    click_button 'Resend'
    expect(page).to have_content 'You will receive an email with instructions'

    email_body = ActionMailer::Base.deliveries.last.body.to_s
    token = if email_body =~ /\?confirmation_token=(.*)\"/ then $1 else '' end
    expect(token).to_not be_blank
  end
end
