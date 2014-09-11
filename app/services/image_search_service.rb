require "searchbing"

class ImageSearchService
  def initialize(query)
    @query = query
    @page = 1
    @per_page = 10
  end

  def paginated_images
    results = client.search(@query, offset).first
    images, total_count = load_images(results, offset)
    Kaminari.paginate_array(images, total_count: total_count,
                                    limit: @per_page,
                                    offset: 0,
                                    padding: offset * -1
                            )
  end

  def page(value)
    @page = value
    self
  end

  def per(value)
    @per_page = value
    paginated_images
  end

  def offset
    @per_page * (@page - 1)
  end

  private # ================================================================

  def client
    @client ||= Bing.new(Rails.application.secrets.bing_account_key,
                         @per_page,
                         "Image"
                        )
  end

  def load_images(results, offset)
    total_count = results[:ImageTotal].to_i
    images = []
    if results[:ImageOffset].to_i >= offset # to prevent duplicated pages
      images = results[:Image].map { |result| BingImage.new(result) }
    end
    [images, total_count]
  end
end
