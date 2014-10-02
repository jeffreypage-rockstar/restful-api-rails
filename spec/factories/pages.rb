# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do
    slug "my-page"
    title "My Page"
    content "<h2>My Page Markdown Content</h2><p>The content</p>"
  end
end
