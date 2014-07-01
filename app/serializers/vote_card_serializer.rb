class VoteCardSerializer < ActiveModel::Serializer
  attributes :user_id, :vote_score, :card_id

  def card_id
    object.votable_id
  end
end
