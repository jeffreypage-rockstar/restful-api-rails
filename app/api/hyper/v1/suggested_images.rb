module Hyper
  module V1
    # api to search images using bing api
    class SuggestedImages < Base
      PAGE_SIZE = 10

      resource :suggested_images do
        # GET /cards
        desc "Returns images suggestion based on a search query, paginated"
        paginate per_page: PAGE_SIZE
        params do
          requires :q, type: String, desc: "The query for image searching"
        end
        get do
          authenticate!
          paginate ImageSearchService.new(params[:q].to_s)
        end
      end
    end
  end
end
