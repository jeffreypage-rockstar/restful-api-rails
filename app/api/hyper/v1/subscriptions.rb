module Hyper
  module V1
    # api to manage current user subscriptions
    class Subscriptions < Base
      PAGE_SIZE = 30

      resource :subscriptions do

        # POST /subscriptions
        desc "Subscribe the current user to a stack or a group of stacks."
        params do
          requires :stacks, type: String,
                            desc: "Stack ids. Use commas to subscribe to a "\
                                  "group of stacks."
        end
        post do
          authenticate!
          stacks = Stack.where(id: params[:stacks].to_s.split(","))
          stacks.map { |stack| current_user.subscribe(stack) }
        end

        # GET /subscriptions
        desc "Returns current user subscriptions, paginated."
        paginate per_page: PAGE_SIZE
        get do
          authenticate!
          paginate current_user.subscribed_stacks.recent
        end

        # DELETE /subscriptions/:stack_id
        desc "Unsubscribe current user from the stack"
        params do
          requires :id, type: String, desc: "Stack id.", uuid: true
        end
        route_param :id do
          delete do
            authenticate!
            current_user.subscriptions.find_by!(stack_id: params[:id]).destroy
            empty_body!
          end
        end
      end
    end
  end
end
