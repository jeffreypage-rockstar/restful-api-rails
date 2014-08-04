include Warden::Test::Helpers
Warden.test_mode!
# Feature: Notification management
#   As an admin
#   I want to manage notifications
#   So I can list notifications
feature "Admin Notification management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list notifications
  #   Given I am an admin
  #   When I try to navigate to notifications page
  #   Then I can see the latest notifications
  scenario "Admin can list system notifications" do
    notification = FactoryGirl.create(:notification)

    page.find("[data-model=notification] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "notification")
    expect(page).to have_content notification.caption
    expect(page).to have_content notification.user.username
    expect(page).to have_content notification.subject.name
  end

  # Scenario: Admin can show notification details
  #   Given I am an admin
  #   When I click to show an existing notification
  #   Then I see notification details
  scenario "admin can show notification details" do
    notification = FactoryGirl.create(:notification)
    page.find("[data-model=notification] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "notification")

    page.find(".notification_row[1] .show_member_link a").click
    expect(current_path).to eq rails_admin.
                               show_path(model_name: "notification",
                                         id: notification.id)

    expect(page).to have_content notification.caption
    expect(page).to have_content notification.user.username
    expect(page).to have_content notification.subject.name
  end

  # Scenario: Admin cannot delete a notification
  #   Given I am an admin
  #   When I try to delete an notification
  #   Then I see an error message
  scenario "admin cannot delete an notification" do
    FactoryGirl.create(:notification)

    page.find("[data-model=notification] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "notification")
    expect do
      page.find(".notification_row[1] .delete_member_link a").click
    end.to raise_error
  end
end
