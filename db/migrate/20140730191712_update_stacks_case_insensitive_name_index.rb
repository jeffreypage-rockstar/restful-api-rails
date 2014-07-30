class UpdateStacksCaseInsensitiveNameIndex < ActiveRecord::Migration
  def up
    remove_index :stacks, :name
    execute "CREATE UNIQUE INDEX index_stacks_on_lowercase_name
             ON stacks USING btree (lower(name));"
  end

  def down
    execute "DROP INDEX index_stacks_on_lowercase_name;"
    add_index :stacks, :name, unique: true
  end
end
