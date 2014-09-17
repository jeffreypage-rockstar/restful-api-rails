class Activity < PublicActivity::Activity
  default_scope { order(created_at: :desc) }
  scope :notified, -> { where(notified: true) }
  scope :not_notified, -> { where(notified: false) }
end
