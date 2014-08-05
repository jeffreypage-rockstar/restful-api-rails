require_relative "notifier/base"
require_relative "notifier/card_create"
require_relative "notifier/comment_create"
require_relative "notifier/card_up_vote"
require_relative "notifier/comment_up_vote"

module Notifier
  def self.notify_async(activity_id, activity_key)
    notifier_name = activity_key.gsub(/\W/, "_").camelize.to_sym
    if constants.include?(notifier_name) && activity_id
      const_get(notifier_name).perform_async(activity_id)
    else
      nil
    end
  end
end
