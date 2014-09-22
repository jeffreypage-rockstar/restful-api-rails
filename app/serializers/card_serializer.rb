require_relative "card_image_serializer"
require_relative "user_short_serializer"

class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :stack_id, :score, :flags_count, :my_vote,
             :source, :comments_count, :created_at, :public_url, :flagged_by_me

  has_many :images, serializer: CardImageSerializer
  has_one :user, serializer: UserShortSerializer

  def my_vote
    VoteCardSerializer.new object.votes.where(user_id: current_user.id).first
  end

  def flagged_by_me
    object.flags.exists? user_id: current_user.id
  end

  def public_url
    h.card_url(object)
  end

  private

  # we cant use card_url helper because rails helper are not accesible
  def h
    @h ||= ::ApiUrlHelpers.new
  end
end
