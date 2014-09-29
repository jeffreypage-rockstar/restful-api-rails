include Warden::Test::Helpers
Warden.test_mode!
# Feature: StackStats management
#   As an admin
#   I want to manage stats
#   So I can list stats
feature "Admin StackStats management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list daily stack stats
  #   Given I am an admin
  #   When I try to navigate to stats page
  #   Then I can see the latest daily stats
  scenario "Admin can list daily stack stats" do
    stats = FactoryGirl.create(:stack_stats)

    page.find("[data-model=stack_stats] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "stack_stats")
    expect(page).to have_content stats.date.strftime("%m/%d/%Y")
    expect(page).to have_content stats.stack.name
    expect(page).to have_content stats.subscriptions
    expect(page).to have_content stats.unsubscriptions
  end

  # Scenario: Admin can list weekly stats
  #   Given I am an admin
  #   When I try to navigate to stats page
  #   Then I can see the latest weekly stats
  scenario "Admin can list weekly stack stats" do
    stats = FactoryGirl.create(:stack_stats)

    page.find("[data-model=stack_stats] a").click
    page.find("a", text: "Weekly").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "stack_stats")
    expect(page).to have_content stats.date.strftime("%m/%Y (4)")
    expect(page).to have_content stats.stack.name
    expect(page).to have_content stats.subscriptions
    expect(page).to have_content stats.unsubscriptions
  end

  # Scenario: Admin can list monthly stats
  #   Given I am an admin
  #   When I try to navigate to stats page
  #   Then I can see the latest monthly stats
  scenario "Admin can list monthly system stats" do
    stats = FactoryGirl.create(:stack_stats)

    page.find("[data-model=stack_stats] a").click
    page.find("a", text: "Monthly").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "stack_stats")
    expect(page).to have_content stats.date.strftime("%m/%Y")
    expect(page).to have_content stats.stack.name
    expect(page).to have_content stats.subscriptions
    expect(page).to have_content stats.unsubscriptions
  end

  # Scenario: Admin cannot delete a stack stats
  #   Given I am an admin
  #   When I try to delete an stats
  #   Then I see an error message
  scenario "admin cannot delete a stack stats" do
    FactoryGirl.create(:stats)

    page.find("[data-model=stack_stats] a").click
    expect(current_path).to eq rails_admin.
                               index_path(model_name: "stack_stats")
    expect do
      page.find(".stack_stats_row[1] .delete_member_link a").click
    end.to raise_error
  end
end
