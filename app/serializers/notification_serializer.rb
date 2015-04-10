class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :caption, :subject_id, :subject_type, :senders, :sent_at,
             :read?, :seen?, :action, :image_url

  MAX_SENDERS = 3

  def senders
    object.senders.limit(MAX_SENDERS).pluck(:user_id, :username).to_h
  end

  def attributes
    data = super
    data.merge!(object.extra) if object.extra.try(:any?)
    data
  end
end
