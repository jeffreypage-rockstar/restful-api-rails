class AddUuidsToUsersAandDevices < ActiveRecord::Migration
  def change
    %w(users devices).each do |table|
      execute <<-SQL
        DELETE FROM #{table};

        ALTER TABLE #{table} ADD COLUMN guid uuid;
        ALTER TABLE #{table} ALTER COLUMN guid SET NOT NULL;
        ALTER TABLE #{table} ALTER COLUMN guid SET DEFAULT uuid_generate_v4();

        ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey;
        ALTER TABLE #{table} DROP COLUMN id;
        ALTER TABLE #{table} RENAME COLUMN guid TO id;
        ALTER TABLE #{table} ADD PRIMARY KEY (id);
      SQL
    end
  end
end
