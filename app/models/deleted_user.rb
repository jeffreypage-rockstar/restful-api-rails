require_relative "user"

class DeletedUser < ActiveRecord::Base
  self.primary_key = :id

  def restore
    user_id = self.class._restore_users(id).first
    destroy if user_id
    user_id
  end

  def self.restore(ids)
    restored_ids = _restore_users(ids)
    if restored_ids.any?
      conditions = sanitize_sql_array(["WHERE id IN (?)", restored_ids])
      connection.execute "DELETE FROM deleted_users #{conditions}"
    end
    restored_ids
  end

  def self._restore_users(user_ids)
    columns = DeletedUser.column_names
    Array(user_ids).map do |uid|
      begin
        conditions = sanitize_sql_array(["WHERE id = ?", uid])
        connection.execute <<-SQL
          INSERT INTO users (#{columns.join(", ")})
          SELECT #{columns.join(", ")}
          FROM deleted_users
          #{conditions}
        SQL
        uid
      rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotUnique
        nil
      end
    end.compact
  end
end
