include Warden::Test::Helpers
Warden.test_mode!
# Feature: Vote management
#   As an admin
#   I want to manage votes
#   So I can list add, edit, and delete votes
feature "Admin vote management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can list the votes
  #   Given I am an admin
  #   When I try access the votes page
  #   Then I can see the recent votes list
  scenario "admin can list votes" do
    vote = FactoryGirl.create(:vote)

    page.find("[data-model=vote] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "vote")
    expect(page).to have_content vote.user.username
    expect(page).to have_content vote.votable.name
  end

  # Scenario: Admin can edit an Vote
  #   Given I am an admin
  #   When I try to edit an existing vote
  #   Then the vote gets edited
  scenario "admin can edit an Vote" do
    vote = FactoryGirl.create(:vote)

    visit rails_admin.edit_path(model_name: "vote", id: vote.id)
    fill_in "Weight", with: "2"
    click_button "Save"

    vote.reload
    expect(vote.weight).to eq 2
  end

  # Scenario: Admin can delete an vote
  #   Given I am an admin
  #   When I try to delete an vote
  #   Then an vote gets deleted
  scenario "admin can delete an vote" do
    FactoryGirl.create(:vote)

    page.find("[data-model=vote] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "vote")
    expect do
      page.find(".vote_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Vote, :count).by(-1)
  end
end
