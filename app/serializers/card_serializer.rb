class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :stack_id, :score, :created_at

  has_many :images, serializer: CardImageSerializer
end
