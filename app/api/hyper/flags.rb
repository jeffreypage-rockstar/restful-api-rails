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
        User.find(params[:user_id]).flag_by!(current_user) if params[:user_id]
        Card.find(params[:card_id]).flag_by!(current_user) if params[:card_id]
        if params[:comment_id]
          comment = Comment.find(params[:comment_id])
          comment.flag_by!(current_user)
        end
        empty_body!
      end
    end
  end
end
