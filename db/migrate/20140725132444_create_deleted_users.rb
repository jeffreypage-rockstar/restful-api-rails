class CreateDeletedUsers < ActiveRecord::Migration
  def up
    execute "CREATE TABLE deleted_users AS SELECT * FROM users WHERE 1=2;"
    execute "ALTER TABLE deleted_users ADD PRIMARY KEY (id);"
  end

  def down
    drop_table :deleted_users
  end
end
