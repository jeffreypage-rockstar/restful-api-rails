module Hyper
  # api to manage stacks
  class Stacks < Base
    PAGE_SIZE = 100

    resource :stacks do
      # POST /stacks
      desc "Create a new stack with current user as owner"
      params do
        requires :name, type: String, desc: "Stack name, must be unique."
        optional :description, type: String, desc: "Stack description."
        optional :protected, type: Boolean, desc: "Stack visibility."
      end
      post do
        authenticate! && authorize!(:create, Stack)
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

      # GET /stacks/popular
      desc "Returns trending stacks, paginated"
      paginate per_page: PAGE_SIZE
      get :popular do
        authenticate!
        paginate Stack.popular(current_user.id)
      end

      # GET /stacks/names
      desc "Returns stacks for an autocomplete box"
      params do
        requires :q, type: String, desc: "The query for stack name lookup."
      end
      paginate per_page: PAGE_SIZE
      get :names, each_serializer: StackShortSerializer do
        authenticate!
        paginate Stack.where("name ILIKE ?", "#{params[:q]}%")
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
