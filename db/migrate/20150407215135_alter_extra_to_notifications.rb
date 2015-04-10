class AlterExtraToNotifications < ActiveRecord::Migration
  def change
    change_column :notifications, :extra, "varchar(255) USING concat("\
                                          "(extra->'stack_id'), ',', "\
                                          "(extra->'card_id'), ',', "\
                                          "(extra->'comment_id'))"
  end
end
