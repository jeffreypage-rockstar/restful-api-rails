module Hyper
  # api to allow current user flag items
  class Flags < Base
    resources :flags do
      # POST /flags
      desc "Flag an item as inappropriate"
      params do
        optional :user_id, type: String, desc: "User id", uuid: true
        optional :card_id, type: String, desc: "Card id", uuid: true
        optional :comment_id, type: String, desc: "Comment id", uuid: true

        mutually_exclusive :user_id, :card_id, :comment_id
      end
      post do
        authenticate!
        klass = User if params[:user_id]
        klass = Card if params[:card_id]
        klass = Comment if params[:comment_id]
        authorize!(:flag, klass)
        klass.find(params["#{klass.name.downcase}_id"]).flag_by!(current_user)
        empty_body!
      end
    end
  end
end
