# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :setting do
    key "read_only_mode"
    value "enabled"
    description "When enabled, not confirmed users can't "\
                "post, comment or vote. Only read is allowed."
  end
end
