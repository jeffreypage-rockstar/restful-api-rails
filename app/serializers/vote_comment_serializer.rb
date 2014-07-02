class VoteCommentSerializer < ActiveModel::Serializer
  attributes :user_id, :kind, :vote_score, :comment_id, :created_at

  def comment_id
    object.votable_id
  end
end
