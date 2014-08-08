require_relative "card_serializer"

class CardStreamSerializer < ActiveModel::Serializer
  attributes :scroll_id, :total_entries
  has_many :cards, serializer: CardSerializer
end
