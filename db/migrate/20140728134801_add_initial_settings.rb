class AddInitialSettings < ActiveRecord::Migration
  def change
    Setting.create! key: "read_only_mode", 
                    value: "enabled",
                    description: "When enabled, not confirmed users can't "\
                                 "post, comment or vote. Only read is allowed."
  end
end
