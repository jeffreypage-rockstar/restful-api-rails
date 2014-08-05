RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
  config.include ActiveSupport::Testing::TimeHelpers, type: :model
end
