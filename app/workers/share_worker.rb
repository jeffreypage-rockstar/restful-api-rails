# A sidekiq worker to share cards using the user available networks
require "tumblr"

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

  def share_twitter(card, network)
    client = Twitter::Client.new
    client.consumer_key       = Rails.application.secrets.twitter_api_key
    client.consumer_secret    = Rails.application.secrets.twitter_api_secret
    client.oauth_token        = network.token
    client.oauth_token_secret = network.secret
    client.update("Check my new card on #Hyper: #{share_url(card)}")
  end

  def share_tumblr(card, network)
    client = Tumblr::Client.new
    client.consumer_key       = Rails.application.secrets.tumblr_api_key
    client.consumer_secret    = Rails.application.secrets.tumblr_api_secret
    client.oauth_token        = network.token
    client.oauth_token_secret = network.secret
    client.link(network.uid, share_url(card),
                "title" => card.name,
                "description" => card.description)
  end

  def perform(user_id, card_id, providers = [])
    return [] unless user = User.find_by(id: user_id)
    return [] unless card = Card.find_by(id: card_id)
    user.networks.where(provider: Array(providers)).each do |network|
      send("share_#{network.provider}", card, network)
    end
  end
end
