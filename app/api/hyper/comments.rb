module Hyper
  # api to create a user and/or get the current user data
  class Comments < Base
    PAGE_SIZE = 30

    namespace "cards/:card_id" do
      params do
        requires :card_id, type: String, desc: "A Card id."
      end

      resource :comments do
        # POST /cards/:card_id/comments
        desc "Create a new comment with current user as owner"
        params do
          optional :body, type: String, desc: "Comment body text"
        end
        post do
          authenticate!
          comment_params = permitted_params
          comment_params[:user_id] = current_user.id
          card = Card.find(params[:card_id])
          comment = card.comments.create!(comment_params.compact)
          header "Location", "/comments/#{comment.id}"
          comment
        end

        # GET /cards/:card_id/comments
        desc "Returns the card comments, paginated"
        paginate per_page: PAGE_SIZE
        params do
          optional :user_id, type: String,
                             desc: "User id to filter comments",
                             uuid: true
          optional :order_by, type: String,
                              values: %w(newest popularity),
                              default: "newest",
                              desc: "Results ordering (newest|popularity)"
        end
        get do
          authenticate!
          klass = Comment
          klass = klass.where(user_id: params[:user_id]) if params[:user_id]
          paginate klass.send(params[:order_by])
        end
      end
    end
  end
end
