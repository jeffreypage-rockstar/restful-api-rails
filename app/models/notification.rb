class Notification < ActiveRecord::Base
  validates :user, :subject, :action, presence: true
  store_accessor :senders
  store_accessor :extra

  belongs_to :user
  belongs_to :subject, polymorphic: true

  scope :unread, -> { where(read_at: nil).order(created_at: :desc) }
  scope :unseen, -> { where(seen_at: nil) }
  scope :seen, -> { where.not(seen_at: nil) }
  scope :not_sent, -> { where(sent_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :recently_sent, -> { sent.order(sent_at: :desc) }

  PUSH_VOTES_INTERVAL = 50
  SENDERS_CAPTION_LIMIT = 3

  def caption
    senders = self[:senders] || {}
    subject_name = subject.try(:name)
    stack_name = subject.try(:stack).try(:name)
    if senders_count <= SENDERS_CAPTION_LIMIT
      user_names = senders.keys.to_sentence(last_word_connector: " and ")
      I18n.t("#{action}.with_user_names", scope: "notifications",
                   count: senders_count, user_names: user_names,
                   subject_name: subject_name, stack_name: stack_name)
    else
      I18n.t("#{action}.with_numbers", scope: "notifications",
                   count: senders_count, subject_name: subject_name,
                   stack_name: stack_name)
    end
  end

  def image_url
    senders = self[:senders] || {}
    if senders.empty?
      nil
    elsif senders.one?
      single_sender_image_url(senders.values.first)
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
    self.senders ||= {}
    self.senders[sender_user.username] = sender_user.id
  end

  def senders_count
    (self.senders || {}).keys.size
  end

  def sent!
    self.sent_at = Time.now.utc
    self.seen_at = nil
    self.read_at = nil
    self.save!
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

  def self.mark_all_as_seen(user_id, before_notification)
    return unless before_notification.sent?
    unseen.where(user_id: user_id).
           where("sent_at <= ?", before_notification.sent_at).
           update_all(seen_at: Time.now.utc)
  end

  private # =======================================

  def single_sender_image_url(sender_id)
    if shows_user_for_single_notification?
      User.find_by_id(sender_id).avatar_url
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
