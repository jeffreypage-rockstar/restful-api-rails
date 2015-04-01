include Warden::Test::Helpers
Warden.test_mode!
# Feature: Stack management
#   As an admin
#   I want to manage stacks
#   So I can list add, edit, and delete stacks
feature "Admin Stack management", :devise do
  before :each do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit rails_admin.dashboard_path
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin can create a new stack
  #   Given I am an admin
  #   When I try to create an stack
  #   Then an stack gets added to the system
  scenario "admin can create an stack" do
    new_user = FactoryGirl.create(:user)
    new_stack = FactoryGirl.attributes_for(:stack)

    page.find("[data-model=stack] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "stack")
    expect do
      visit rails_admin.new_path(model_name: "stack")
      fill_in "Hashtag", with: new_stack[:name]
      fill_in "Description", with: new_stack[:description]
      select new_user.username, from: "stack[user_id]"
      click_button "Save"
    end.to change(Stack, :count).by(1)
    expect(current_path).to eq rails_admin.index_path(model_name: "stack")
    expect(page).to have_content new_stack[:name]
    expect(page).to have_content new_user[:username]
  end

  # Scenario: Admin can edit an Stack
  #   Given I am an admin
  #   When I try to edit an existing stack
  #   Then the stack gets edited
  scenario "admin can edit an Stack" do
    stack = FactoryGirl.create(:stack)

    visit rails_admin.edit_path(model_name: "stack", id: stack.id)
    fill_in "Hashtag", with: "anothername"
    fill_in "Description", with: "anotherdescription"
    fill_in "Subscriptions", with: "10"
    click_button "Save"

    stack.reload
    expect(stack.name).to eq "anothername"
    expect(stack.description).to eq "anotherdescription"
    expect(stack.subscriptions_count).to eq 10
  end

  # Scenario: Admin can delete an stack
  #   Given I am an admin
  #   When I try to delete an stack
  #   Then an stack gets deleted
  scenario "admin can delete an stack" do
    FactoryGirl.create(:stack)

    page.find("[data-model=stack] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "stack")
    expect do
      page.find(".stack_row[1] .delete_member_link a").click
      click_button "Yes, I'm sure"
    end.to change(Stack, :count).by(-1)
  end

  # Scenario: Admin can import stacks from a csv file
  #   Given I am an admin
  #   When I try to import stacks
  #   Then new stacks are created
  scenario "admin can import stacks from a csv file" do
    create(:user, id: "3ccf87b1-c3ec-4c94-97f6-bd524ab001a1")
    file_path = File.expand_path("../../../fixtures/some_stacks.csv", __FILE__)
    page.find("[data-model=stack] a").click
    expect(current_path).to eq rails_admin.index_path(model_name: "stack")
    expect do
      page.find(".import_collection_link a").click
      page.find("#file").set(file_path)
      click_button "Import"
    end.to change(Stack, :count).by(3)
  end

end
