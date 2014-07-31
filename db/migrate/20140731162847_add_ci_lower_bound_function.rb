class AddCiLowerBoundFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace function ci_lower_bound(ups integer, downs integer) returns numeric as $$
    select (case($1 + $2) when 0 then 0
            else (($1 + 1.9208) / ($1 + $2) -
                   1.96 * SQRT(($1 * $2) / ($1 + $2) + 0.9604) /
                          ($1 + $2)) / (1 + 3.8416 / ($1 + $2)) end)
$$ language sql immutable;
    SQL

    execute "CREATE INDEX index_comments_rank ON comments ((ci_lower_bound(up_score, down_score)));"
  end

  def down
    execute "DROP INDEX index_comments_rank;"
    execute "DROP FUNCTION IF EXISTS ci_lower_bound(integer, integer);"
  end
end
