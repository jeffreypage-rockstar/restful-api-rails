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
        optional :user_id, type: String, desc: 'User id to filter cards.'
      end
      get do
        # TODO: allow sorting by popularity
        authenticate!
        klass = Card.includes(:images)
        klass = klass.where(stack_id: params[:stack_id]) if params[:stack_id]
        klass = klass.where(user_id: params[:user_id]) if params[:user_id]
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

      # PUT /cards/:id
      desc 'Update the card data'
      params do
        optional :name, type: String, desc: 'New card name.'
        optional :stack_id, type: String, desc: 'Stack id where card should'\
                                                ' be moved.'
        optional :images, type: Array, desc: 'Card images list to be added' do
          requires :image_url, type: String, desc: 'Image url'
          requires :caption, type: String, desc: 'Image caption'
        end
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
          empty_body!
        end
      end

      # DELETE /user
      desc 'Deletes a card'
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
