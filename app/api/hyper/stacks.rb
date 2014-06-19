module Hyper
  # api to create a user and/or get the current user data
  class Stacks < Base
    PAGE_SIZE = 30
    AUTOCOMPLETE_SIZE = 10

    resource :stacks do
      # POST /stacks
      desc 'Create a new stack with current user as owner'
      params do
        requires :name, type: String, desc: 'Stack name, must be unique.'
        optional :protected, type: Boolean, desc: 'Stack visibility.'
      end
      post do
        authenticate!
        current_user.stacks.create!(
          name: params[:name],
          protected: params[:protected]
        )
      end

      # GET /stacks
      desc 'Returns current user stacks, paginated'
      paginate per_page: PAGE_SIZE
      get do
        authenticate!
        paginate current_user.stacks.recent
      end

      # GET /stacks/suggestions
      desc 'Returns suggested stacks for current user'
      get :suggestions do
        authenticate!
        Stack.where('random() < 0.01').limit(PAGE_SIZE)
      end

      # GET /stacks/related
      desc 'Returns related stacks given a list of stacks, paginated'
      paginate per_page: PAGE_SIZE
      params do
        requires :stacks, type: Array, desc: 'A list of stack ids.'
      end
      get :related do
        authenticate!
        paginate Stack.where.not(user_id: current_user.id).recent
      end

      # GET /stacks/names
      desc 'Returns stacks for an autocomplete box'
      params do
        requires :q, type: String, desc: 'The query for stack name lookup.'
      end
      get :names, each_serializer: StackShortSerializer, root: false do
        authenticate!
        Stack.where('name ILIKE ?', "#{params[:q]}%").limit(AUTOCOMPLETE_SIZE)
      end

      # GET /stacks/:id
      desc 'Returns the stack details'
      params do
        requires :id, type: String, desc: 'Stack id.'
      end
      route_param :id do
        get do
          authenticate!
          Stack.find_by!(id: params[:id])
        end
      end
    end
  end
end
