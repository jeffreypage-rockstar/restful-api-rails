class NotificationSerializer < ActiveModel::Serializer
  attributes :caption, :subject_id, :subject_type, :senders, :sent_at,
             :read?, :seen?, :action, :image_url, :id
end
