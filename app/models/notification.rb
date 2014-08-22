class Notification < ActiveRecord::Base
  validates :user, :subject, :action, presence: true
  store_accessor :senders

  belongs_to :user
  belongs_to :subject, polymorphic: true

  scope :unread, -> { where(read_at: nil).order(created_at: :desc) }
  scope :unseen, -> { where(seen_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  PUSH_VOTES_INTERVAL = 50
  SENDERS_CAPTION_LIMIT = 3
  MAX_DEVICES = 3

  def caption
    result = []
    senders = self[:senders] || {}
    if senders.empty?
      result << "a person has"
    elsif senders.size.to_i > SENDERS_CAPTION_LIMIT
      result << "#{senders.size} people have"
    else
      result << senders.keys.to_sentence(last_word_connector: " and ")
      result << "have"
    end
    result << I18n.t(action, scope: "notifications")
    result.delete_if(&:blank?).join(" ")
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

  def send!
    if user.present? && require_push_notification?
      sns = AWS::SNS.new.client
      user.devices.with_arn.recent.limit(MAX_DEVICES).
      pluck(:sns_arn).uniq.each do |arn|
        sns.publish(message_attributes.merge(target_arn: arn))
      end
    end
    self.sent_at = Time.now.utc
    save
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
    unread.where(user_id: user_id).
           where("created_at <= ?", before_notification.created_at).
           update_all(read_at: Time.now.utc)
  end

  def self.mark_all_as_seen(user_id, before_notification)
    unseen.where(user_id: user_id).
           where("created_at <= ?", before_notification.created_at).
           update_all(seen_at: Time.now.utc)
  end

  private # =======================================

  def message_attributes
    @message_attributes ||= {
      message: caption,
      message_attributes: {
        "subject_id" => { data_type: "String", string_value: subject_id },
        "subject_type" => { data_type: "String", string_value: subject_type }
      }
    }
  end
end
