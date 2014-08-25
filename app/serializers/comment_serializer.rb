require_relative "user_short_serializer"

class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :user_id, :card_id, :score, :flags_count,
             :my_vote, :created_at, :replying_id, :mentions, :flagged_by_me

  has_one :user, serializer: UserShortSerializer

  def my_vote
    VoteCardSerializer.new object.votes.where(user_id: current_user.id).first
  end

  def flagged_by_me
    object.flags.exists? user_id: current_user.id
  end
end
