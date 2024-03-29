module Hyper
  module V1
    # api to manage cards
    class Cards < Base
      PAGE_SIZE = 30

      resource :cards do
        # POST /cards
        desc "Create a new card with current user as owner"
        params do
          requires :name, type: String, desc: "Card name."
          requires :stack_id, type: String, desc: "Stack id where card is "\
                                                  "being created."
          optional :images, type: Array, desc: "Card images list" do
            requires :image_url, type: String, desc: "Image url"
            optional :caption, type: String, desc: "Image caption"
          end
          optional :source, type: String, values: Card::SOURCES,
                            default: "device",
                            desc: "Card images source (device, bing, ...)"
          optional :share, type: Array, desc: "List of social networks to "\
                                              "share the new card"
        end
        post do
          authenticate! && authorize!(:create, Card)
          card_params = permitted_params
          card_params[:images_attributes] = card_params.delete(:images)
          card_params[:user_id] = current_user.id
          networks_to_share = Array(card_params.delete(:share))
          stack = Stack.find(params[:stack_id])
          card = stack.cards.create!(card_params.compact)
          # auto subscribe when creating a card
          current_user.subscribe(stack)
          # auto sharing to social networks
          if networks_to_share.any?
            ShareWorker.perform_async(
              current_user.id, card.id, networks_to_share
            )
          end
          header "Location", "/cards/#{card.id}"
          card
        end

        # GET /cards
        desc "Returns front page cards or the stack cards, "\
             "paginated with scroll"
        params do
          optional :stack_id, type: String,
                              desc: "Stack id to filter cards",
                              uuid: true
          optional :user_id, type: String,
                             desc: "User id to filter cards",
                             uuid: true
          optional :order_by, type: String,
                              values: %w(newest popularity),
                              default: "newest",
                              desc: "Results ordering (newest|popularity)"
          optional :scroll_id, type: String,
                               desc: "Scroll_id is required to get the next "\
                                     "cards set."
          optional :per_page, type: Integer,
                              default: PAGE_SIZE,
                              desc: "Number of results to return per page."
        end
        get nil, serializer: CardStreamSerializer do
          authenticate!
          CardStreamService.new(permitted_params).execute
        end

        # GET /cards/upvoted
        desc "Returns cards upvoted by the current_user, paginated"
        paginate per_page: PAGE_SIZE
        get :upvoted do
          authenticate!
          paginate Card.up_voted_by(current_user.id).includes(:images)
        end

        # GET /cards/:id
        desc "Returns the card details"
        params do
          requires :id, type: String, desc: "Card id.", uuid: true
        end
        route_param :id do
          get do
            authenticate!
            Card.includes(:images).find(params[:id])
          end
        end

        # GET /cards/:id/votes
        desc "Returns the card votes"
        paginate per_page: PAGE_SIZE
        params do
          requires :id, type: String, desc: "Card id.", uuid: true
        end
        route_param :id do
          get :votes, each_serializer: VoteCardSerializer do
            authenticate!
            paginate Card.find(params[:id]).votes.recent
          end
        end

        # POST /cards/:id/votes
        desc "Cast a vote to the card"
        params do
          requires :id, type: String, desc: "Card id.", uuid: true
          optional :kind, type: String, values: %w(up down), default: "up",
                          desc: "Vote kind can be up or down. Default is up."
        end
        route_param :id do
          post :votes, serializer: VoteCardSerializer do
            authenticate! && authorize!(:vote, Card)
            Card.find(params[:id]).vote_by!(current_user, kind: params[:kind])
          end
        end

        # PUT /cards/:id
        desc "Update the card data"
        params do
          requires :id, type: String, desc: "Card id", uuid: true
          optional :name, type: String, desc: "New card name."
          optional :stack_id, type: String,
                              desc: "Stack id where card should be moved.",
                              uuid: true
          optional :images, type: Array, desc: "Card images list to be added" do
            requires :image_url, type: String, desc: "Image url"
            optional :caption, type: String, desc: "Image caption"
          end
          optional :source, type: String, values: Card::SOURCES,
                            default: "device",
                            desc: "Card images source (device, bing, ...)"
        end
        route_param :id do
          put do
            authenticate!
            card = Card.find(params[:id])
            forbidden! if card.user_id != current_user.id

            stack = Stack.find(params[:stack_id]) if params[:stack_id]
            card_params = permitted_params
            card_params[:images_attributes] = card_params.delete(:images)
            card_params[:stack] = stack
            card.update_attributes!(card_params.compact)
            card
          end
        end

        # DELETE /cards/:id
        desc "Deletes a card"
        params do
          requires :id, type: String, desc: "Card id", uuid: true
        end
        route_param :id do
          delete do
            authenticate!
            card = Card.find(params[:id])
            forbidden! if card.user_id != current_user.id
            card.destroy!
            empty_body!
          end
        end
      end
    end
  end
end
