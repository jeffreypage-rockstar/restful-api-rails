class NotificationSerializer < ActiveModel::Serializer
  SENDERS_LIMIT = 3

  attributes :caption, :subject_id, :subject_type, :senders, :sent_at, :read?

  def caption
    result = []
    senders = object.senders || {}
    if senders.empty?
      result << "a person has"
    elsif senders.size.to_i > SENDERS_LIMIT
      result << "#{senders.size} people have"
    else
      result << senders.keys.to_sentence(last_word_connector: " and ")
      result << "have"
    end
    result << I18n.t(object.action, scope: "notifications")
    result.delete_if(&:blank?).join(" ")
  end
end
