module Hyper
  # api to create a user and/or get the current user data
  class Stacks < Base
    PAGE_SIZE = 30
    AUTOCOMPLETE_SIZE = 10

    resource :stacks do
      # POST /stacks
      desc "Create a new stack with current user as owner"
      params do
        requires :name, type: String, desc: "Stack name, must be unique."
        optional :description, type: String, desc: "Stack description."
        optional :protected, type: Boolean, desc: "Stack visibility."
      end
      post do
        authenticate!
        stack = current_user.stacks.create!(permitted_params)
        header "Location", "/stacks/#{stack.id}"
        stack
      end

      # GET /stacks
      desc "Returns current user stacks, paginated"
      paginate per_page: PAGE_SIZE
      get do
        authenticate!
        paginate current_user.stacks.recent
      end

      # GET /stacks/trending
      desc "Returns trending stacks, paginated"
      paginate per_page: PAGE_SIZE
      get :trending do
        authenticate!
        paginate Stack.trending(current_user.id)
      end

      # GET /stacks/names
      desc "Returns stacks for an autocomplete box"
      params do
        requires :q, type: String, desc: "The query for stack name lookup."
      end
      get :names, each_serializer: StackShortSerializer do
        authenticate!
        Stack.where("name ILIKE ?", "#{params[:q]}%").limit(AUTOCOMPLETE_SIZE)
      end

      # GET /stacks/menu
      desc "Returns an object with user created, subscribed and trending stacks"
      get :menu, serializer: StackMenuSerializer do
        authenticate!
        StackMenu.new.load(current_user)
      end

      # GET /stacks/:id
      desc "Returns the stack details"
      params do
        requires :id, type: String, desc: "Stack id.", uuid: true
      end
      route_param :id do
        get do
          authenticate!
          Stack.find(params[:id])
        end
      end
    end
  end
end
