class NotificationSerializer < ActiveModel::Serializer
  SENDERS_LIMIT = 3

  attributes :caption, :subject_id, :subject_type, :senders, :sent_at, :read?
end
