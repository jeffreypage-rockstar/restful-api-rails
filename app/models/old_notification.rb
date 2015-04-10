class OldNotification < ActiveRecord::Base
  def extra
    extra_hash = self[:extra]
    extra_hash.symbolize_keys!
    values = extra_hash.values_at(:stack_id, :card_id, :comment_id)
    values.delete_if(&:blank?).join(",")
  end
end
