module Hyper
  # api to create a user and/or get the current user data
  class Cards < Base
    PAGE_SIZE = 30

    resource :cards do
      # POST /cards
      desc 'Create a new card with current user as owner'
      params do
        requires :name, type: String, desc: 'Card name.'
        requires :stack_id, type: String, desc: 'Stack id where card is been'\
                                                ' created.'
        optional :images, type: Array, desc: 'Card images list' do
          requires :image_url, type: String, desc: 'Image url'
          requires :caption, type: String, desc: 'Image caption'
        end
      end
      post do
        authenticate!
        card_params = permitted_params
        card_params[:images_attributes] = card_params.delete(:images)
        card_params[:user_id] = current_user.id
        stack = Stack.find(params[:stack_id])
        card = stack.cards.create!(card_params.compact)
        header 'Location', "/cards/#{card.id}"
        card
      end

      # GET /cards
      desc 'Returns front page cards or the stack cards, paginated'
      paginate per_page: PAGE_SIZE
      params do
        optional :stack_id, type: String, desc: 'Stack id to filter cards.'
      end
      get do
        # TODO: allow sorting by popularity
        authenticate!
        klass = Card.includes(:images)
        klass = klass.where(stack_id: params[:stack_id]) if params[:stack_id]
        paginate klass.recent
      end

      # GET /cards/:id
      desc 'Returns the card details'
      params do
        requires :id, type: String, desc: 'Card id.'
      end
      route_param :id do
        get do
          authenticate!
          Card.includes(:images).find(params[:id])
        end
      end

      # GET /cards/:id/votes
      desc 'Returns the card votes (WIP)'
      params do
        requires :id, type: String, desc: 'Card id.'
      end
      route_param :id do
        get 'votes' do
          authenticate!
          # Card.includes(:images).find(params[:id])
        end
      end
    end
  end
end
