# A sidekiq worker to share cards using the user available networks
class ShareWorker
  include Sidekiq::Worker
  include CardsHelper

  def share_facebook(card, network)
    graph = Koala::Facebook::API.new(network.token)
    image_url = card.images.first.try(:image_url)
    graph.put_wall_post("I've created a card on Hyper. Check this out!",
                        name: card.name,
                        link: share_url(card),
                        caption: card.description,
                        picture: image_url
                        )
  end

  def share_twitter(_card, _network)
  end

  def share_tumblr(_card, _network)
  end

  def perform(user_id, card_id, providers = [])
    return [] unless user = User.find_by(id: user_id)
    return [] unless card = Card.find_by(id: card_id)
    user.networks.where(provider: Array(providers)).map do |network|
      send("share_#{network.provider}", card, network)
    end
  end
end
