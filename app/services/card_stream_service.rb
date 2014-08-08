require "searchkick/query_with_scroll"
# service responsible to query elasticsearch for cards using the scroll feature
# provides a way to load cards in batches while keeping the ranking order
class CardStreamService
  PAGE_SIZE = 30
  SCROLL_TTL = "5m"

  attr_accessor :options, :cards, :scroll_id, :total_entries

  def initialize(options = {})
    self.options = Hashie::Mash.new(options)
  end

  def read_attribute_for_serialization(attribute)
    send(attribute)
  end

  def execute
    if options.scroll_id.present?
      response = Searchkick.client.scroll(scroll_options)
      search = Searchkick::Results.new(Card, response, search_options)
    else
      query = Searchkick::QueryWithScroll.new(Card, "*", search_options)
      search = query.execute
    end
    self.cards = search.results
    self.scroll_id = search.response["_scroll_id"]
    self.total_entries = search.total_entries
    self
  rescue Elasticsearch::Transport::Transport::Errors::InternalServerError => e
    if e.message =~ /SearchContextMissingException/
      raise ArgumentError.new("invalid or expired scroll_id")
    else
      raise e
    end
  end

  private # ====================================================

  def search_options
    result = default_search_options
    result[:where][:stack_id] = options.stack_id if options.stack_id
    result[:where][:user_id]  = options.user_id if options.user_id
    result[:order] = { hot_score: :desc } if options.order_by == "popularity"
    result[:per_page] = options.per_page || PAGE_SIZE
    result[:scroll] = SCROLL_TTL
    result
  end

  def default_search_options
    { load: true, include: :images, where: {}, order: { created_at: :desc } }
  end

  def scroll_options
    { scroll_id: options.scroll_id, scroll: SCROLL_TTL }
  end
end
