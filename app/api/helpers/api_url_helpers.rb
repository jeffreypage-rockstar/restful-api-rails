class ApiUrlHelpers
  def initialize
    @protocol = "http://"
    @host = Rails.application.secrets.domain_name
  end

  def card_url(card)
    URI.join(@protocol + @host, "/c/", card.hash_id).to_s
  end
end
