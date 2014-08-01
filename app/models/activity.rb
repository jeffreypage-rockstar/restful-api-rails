class Activity < PublicActivity::Activity
  default_scope { order(created_at: :desc) }
end