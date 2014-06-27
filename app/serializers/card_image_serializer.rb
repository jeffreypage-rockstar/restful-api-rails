class CardImageSerializer < ActiveModel::Serializer
  attributes :id, :image_url, :position, :created_at
end
