class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :caption, :subject_id, :subject_type, :senders, :sent_at,
             :read?, :seen?, :action, :image_url

  def senders
    object.senders.limit(Notification::SENDERS_CAPTION_LIMIT).
                   pluck(:username, :user_id).to_h
  end

  def attributes
    data = super
    data.merge!(object.extra) if object.extra.try(:any?)
    data
  end
end
