class Notification < ActiveRecord::Base
  validates :user, :subject, :action, presence: true

  belongs_to :user
  belongs_to :subject, polymorphic: true

  has_many :senders, class_name: "NotificationSender", dependent: :destroy

  scope :unread, -> { where(read: false) }
  scope :unseen, -> { where(seen: false) }
  scope :seen, -> { where(seen: true) }
  scope :not_sent, -> { where(sent_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :recently_sent, -> { sent.order(sent_at: :desc) }

  PUSH_VOTES_INTERVAL = 50
  SENDERS_CAPTION_LIMIT = 3

  def extra_raw=(value)
    self[:extra] = value
  end

  def extra=(extra_hash)
    extra_hash.symbolize_keys!
    values = extra_hash.values_at(:stack_id, :card_id, :comment_id)
    self[:extra] = values.join(",")
  end

  def extra
    if self[:extra]
      stack, card, comment = self[:extra].split(",")
      {
        "stack_id" => stack,
        "card_id" => card,
        "comment_id" => comment
      }.delete_if { |_k, v| v.blank? }
    else
      {}
    end
  end

  def caption
    subject_name = subject.try(:name)
    sender_names = senders.map(&:username).uniq
    if sender_names.size <= SENDERS_CAPTION_LIMIT
      user_names = sender_names.to_sentence(last_word_connector: " and ")
      I18n.t("#{action}.with_user_names", scope: "notifications",
                   count: sender_names.size, user_names: user_names,
                   subject_name: subject_name)
    else
      I18n.t("#{action}.with_numbers", scope: "notifications",
                   count: sender_names.size, subject_name: subject_name)
    end
  end

  def image_url
    case senders_count
    when 0
      nil
    when 1
      single_sender_image_url
    else
      multiple_senders_image_url
    end
  end

  def mask_as_read!
    self.read = true
    save
  end

  def add_sender(sender_user)
    return unless sender_user
    senders.create(username: sender_user.username, user_id: sender_user.id)
  end

  def sent!
    return false if user.nil?
    clear_association_cache
    self.sent_at = Time.now.utc
    self.seen = false
    self.read = false
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
           update_all(read: true)
  end

  def self.mark_all_as_seen(user_id)
    unseen.where(user_id: user_id).update_all(seen: true)
    User.update user_id, unseen_notifications_count: 0
  end

  def self.mark_all_as_sent(notification_ids)
    where(id: notification_ids).update_all(
      sent_at: Time.now.utc,
      seen: false,
      read: false
    )
  end

  def self.single_sender_caption(subject, action, sender_user)
    subject_name = subject.try(:name)
    I18n.t("#{action}.with_user_names", scope: "notifications",
                   count: 1, user_names: sender_user.username,
                   subject_name: subject_name)
  end

  private # =======================================

  def single_sender_image_url
    if shows_user_for_single_notification?
      User.where(id: senders.map(&:user_id)).first.try(:avatar_url)
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
