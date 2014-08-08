class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :user_id, :username, :card_id, :score, :flags_count,
             :my_vote, :created_at, :replying_id, :mentions

  def my_vote
    VoteCardSerializer.new object.votes.where(user_id: current_user.id).first
  end

  def username
    object.user.try(:username)
  end
end
