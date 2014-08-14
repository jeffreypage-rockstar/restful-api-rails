module Flaggable
  extend ActiveSupport::Concern

  included do
    has_many :flags, as: :flaggable

    scope :flagged, -> { where("flags_count > 0") }
  end

  def flag_by!(user)
    flag = flags.find_or_create_by!(user_id: user.id)
    log_flag(user)
    flag
  end

  def log_flag(user)
    return unless respond_to? :create_activity
    create_activity(:flag, owner: user)
  end
end
