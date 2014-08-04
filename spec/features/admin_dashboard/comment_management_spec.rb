include Warden::Test::Helpers
Warden.test_mode!
# Feature: Comment management
#   As an admin
#   I want to manage comments
#   So I can list add, edit, and delete comments
feature "Admin Comment management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create a new comment
  #   Given I am an admin
  #   When I try to create an comment
  #   Then an comment gets added to the system
  scenario "admin can create an comment" do
    new_user = FactoryGirl.create(:user)
    new_card = FactoryGirl.create(:card)
    new_comment = FactoryGirl.attributes_for(:comment)

    page.find("[data-model=comment] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "comment")
    expect do
      visit rails_admin.new_path(model_name: "comment")
      fill_in "Body", with: new_comment[:body]
      select new_card.name, from: "comment[card_id]"
      select new_user.username, from: "comment[user_id]"
      click_button "Save"
    end.to change(Comment, :count).by(1)
    expect(current_path).to eq rails_admin.index_path(model_name: "comment")
    expect(page).to have_content new_comment[:body]
    expect(page).to have_content new_card[:name]
    expect(page).to have_content new_user[:username]
  end

  # Scenario: Admin can edit an Comment
  #   Given I am an admin
  #   When I try to edit an existing comment
  #   Then the comment gets edited
  scenario "admin can edit an Comment" do
    comment = FactoryGirl.create(:comment)

    visit rails_admin.edit_path(model_name: "comment", id: comment.id)
    fill_in "Body", with: "another comment body"
    click_button "Save"

    comment.reload
    expect(comment.body).to eq "another comment body"
  end

  # Scenario: Admin can delete an comment
  #   Given I am an admin
  #   When I try to delete an comment
  #   Then an comment gets deleted
  scenario "admin can delete an comment" do
    FactoryGirl.create(:comment)

    page.find("[data-model=comment] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "comment")
    expect do
      page.find(".comment_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Comment, :count).by(-1)
  end
end
