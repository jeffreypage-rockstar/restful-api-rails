include Warden::Test::Helpers
Warden.test_mode!
# Feature: Subscription management
#   As an admin
#   I want to manage subscriptions
#   So I can list add, edit, and delete subscriptions
feature "Admin Subscription management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create a new subscription
  #   Given I am an admin
  #   When I try to create an subscription
  #   Then an subscription gets added to the system
  scenario "admin can create an subscription" do
    new_user = FactoryGirl.create(:user)
    new_stack = FactoryGirl.create(:stack)

    page.find("[data-model=subscription] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "subscription")
    expect do
      visit rails_admin.new_path(model_name: "subscription")
      select new_stack.name, from: "subscription[stack_id]"
      select new_user.username, from: "subscription[user_id]"
      click_button "Save"
    end.to change(Subscription, :count).by(1)
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "subscription")
    expect(page).to have_content new_stack[:name]
    expect(page).to have_content new_user[:username]
  end

  # Scenario: Admin can edit an Subscription
  #   Given I am an admin
  #   When I try to edit an existing subscription
  #   Then the subscription gets edited
  scenario "admin can edit an Subscription" do
    subscription = FactoryGirl.create(:subscription)
    new_stack = FactoryGirl.create(:stack)
    visit rails_admin.
          edit_path(model_name: "subscription", id: subscription.id)
    select new_stack.name, from: "subscription[stack_id]"
    click_button "Save"

    subscription.reload
    expect(subscription.stack_id).to eq new_stack.id
  end

  # Scenario: Admin can delete an subscription
  #   Given I am an admin
  #   When I try to delete an subscription
  #   Then an subscription gets deleted
  scenario "admin can delete an subscription" do
    FactoryGirl.create(:subscription)

    page.find("[data-model=subscription] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "subscription")
    expect do
      page.find(".subscription_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Subscription, :count).by(-1)
  end

end
