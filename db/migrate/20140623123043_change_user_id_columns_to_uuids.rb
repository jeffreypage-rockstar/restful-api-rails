class ChangeUserIdColumnsToUuids < ActiveRecord::Migration
  def change
    %w(devices stacks).each do |table|
      execute "DELETE FROM #{table}"
      add_column table, :uuid_user_id, :uuid
      remove_column table, :user_id
      rename_column table, :uuid_user_id, :user_id
    end
  end
end
