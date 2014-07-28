require_relative "card_image_serializer"
require_relative "user_short_serializer"

class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :stack_id, :score, :flags_count, :my_vote,
             :comments_count, :created_at

  has_many :images, serializer: CardImageSerializer
  has_one :user, serializer: UserShortSerializer

  def my_vote
    VoteCardSerializer.new object.votes.where(user_id: current_user.id).first
  end
end
