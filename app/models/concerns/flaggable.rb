module Flaggable
  extend ActiveSupport::Concern

  included do
    has_many :flags, as: :flaggable
  end

  def flag_by(user)
    flags.find_or_create_by(user_id: user.id)
  end
end
