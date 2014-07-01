class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :stack_id, :score, :my_vote, :created_at

  has_many :images, serializer: CardImageSerializer

  def my_vote
    VoteCardSerializer.new object.votes.where(user_id: current_user.id).first
  end
end
