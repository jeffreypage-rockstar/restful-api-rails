class CardImageSerializer < ActiveModel::Serializer
  attributes :id, :image_url, :thumbnail_url, :position, :caption, :created_at
end
