class VoteCardSerializer < ActiveModel::Serializer
  attributes :user_id, :kind, :vote_score, :card_id, :created_at

  def card_id
    object.votable_id
  end
end
