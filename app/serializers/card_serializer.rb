class CardSerializer < ActiveModel::Serializer
  attributes :id, :name, :user_id, :stack_id, :created_at

  has_many :images, serializer: CardImageSerializer
end
