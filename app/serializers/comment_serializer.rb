class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :user_id, :card_id, :score, :flags_count, :my_vote,
             :created_at, :replying_id, :mentions

  def my_vote
    VoteCardSerializer.new object.votes.where(user_id: current_user.id).first
  end
end
