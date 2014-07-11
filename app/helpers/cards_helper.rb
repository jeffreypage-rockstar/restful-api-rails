module CardsHelper
  def hashids
    Hashids.new("Hyper card short_id salt")
  end

  def share_url(card)
    [
      "http:/",
      Rails.application.secrets.domain_name,
      "c",
      hashids.encrypt(card.short_id)
    ].join("/")
  end
end
