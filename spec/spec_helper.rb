require "vcr"
require "public_activity"
require "public_activity/testing"

PublicActivity.enabled = false

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
