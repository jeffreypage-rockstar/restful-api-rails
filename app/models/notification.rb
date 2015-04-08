class Notification < ActiveRecord::Base
  validates :user, :subject, :action, presence: true
  store_accessor :senders

  belongs_to :user
  belongs_to :subject, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  scope :unseen, -> { where(seen_at: nil) }
  scope :seen, -> { where.not(seen_at: nil) }
  scope :not_sent, -> { where(sent_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :recently_sent, -> { sent.order(sent_at: :desc) }

  PUSH_VOTES_INTERVAL = 50
  SENDERS_CAPTION_LIMIT = 3

  def extra=(extra_hash)
    extra_hash.symbolize_keys!
    values = extra_hash.values_at(:stack_id, :card_id, :comment_id)
    self[:extra] = values.join(",")
  end

  def extra
    if self[:extra]
      stack, card, comment = self[:extra].split(',')
      extra_hash = {"card_id" => card, "stack_id" => stack, "comment_id" => comment}
      extra_hash.delete_if {|k, v| v.blank?}
    else
      {}
    end
  end

  def caption
    senders = self[:senders] || {}
    subject_name = subject.try(:name)
    if senders_count <= SENDERS_CAPTION_LIMIT
      user_names = senders.keys.to_sentence(last_word_connector: " and ")
      I18n.t("#{action}.with_user_names", scope: "notifications",
                   count: senders_count, user_names: user_names,
                   subject_name: subject_name)
    else
      I18n.t("#{action}.with_numbers", scope: "notifications",
                   count: senders_count, subject_name: subject_name)
    end
  end

  def image_url
    senders = self[:senders] || {}
    if senders.empty?
      nil
    elsif senders.one?
      single_sender_image_url
    else
      multiple_senders_image_url
    end
  end

  def mask_as_read!
    self.read_at = Time.now.utc
    save
  end

  def read?
    read_at.present?
  end

  def seen?
    seen_at.present?
  end

  def add_sender(sender_user)
    return unless sender_user
    senders_will_change!
    self.senders ||= {}
    self.senders[sender_user.username] = sender_user.id
  end

  def senders_count
    (self.senders || {}).keys.size
  end

  def sent!
    return false if user.nil?
    clear_association_cache
    self.sent_at = Time.now.utc
    self.seen_at = nil
    self.read_at = nil
    self.save!
    User.increment_counter(:unseen_notifications_count, user_id) && user.reload
  end

  def sent?
    sent_at.present?
  end

  def similar_notifications
    Notification.where(action: action, subject: subject).where.not(id: id)
  end

  # for upvotes, send a push notification for the first upvote
  # and then one for every subsequent 50 upvotes
  def require_push_notification?
    if action =~ /up_vote/ && subject.respond_to?(:votes)
      first_notification = !similar_notifications.exists?
      first_notification || subject.votes.count % PUSH_VOTES_INTERVAL == 0
    else
      true
    end
  end

  # CLASS METHODS =======================

  def self.mark_all_as_read(user_id, before_notification)
    return unless before_notification.sent?
    unread.where(user_id: user_id).
           where("sent_at <= ?", before_notification.sent_at).
           update_all(read_at: Time.now.utc)
  end

  def self.mark_all_as_seen(user_id)
    unseen.where(user_id: user_id).update_all(seen_at: Time.now.utc)
    User.update user_id, unseen_notifications_count: 0
  end

  private # =======================================

  def single_sender_image_url
    if shows_user_for_single_notification?
      User.where(id: senders.values).first.try(:avatar_url)
    else
      multiple_senders_image_url
    end
  end

  def shows_user_for_single_notification?
    !["subscription.create", "card.create"].include?(action)
  end

  def multiple_senders_image_url
    subject.try(:notification_image_url)
  end
end
