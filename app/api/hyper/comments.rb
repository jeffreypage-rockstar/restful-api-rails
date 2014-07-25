module Hyper
  # api to manage card comments
  class Comments < Base
    PAGE_SIZE = 30

    namespace "cards/:card_id" do
      params do
        requires :card_id, type: String, desc: "A Card id.", uuid: true
      end

      resource :comments do
        # POST /cards/:card_id/comments
        desc "Create a new comment with current user as owner"
        params do
          optional :body, type: String, desc: "Comment body text"
          optional :replying_id, type: String,
                                 desc: "Replyed comment id",
                                 uuid: true
        end
        post do
          authenticate! && authorize!(:create, Comment)
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

    resource :comments do
      # GET /comments/:id
      desc "Returns the comment details"
      params do
        requires :id, type: String, desc: "Comment id.", uuid: true
      end
      route_param :id do
        get do
          authenticate!
          Comment.find(params[:id])
        end
      end

      # DELETE /comments/:id
      desc "Deletes a comment"
      params do
        requires :id, type: String, desc: "Comment id", uuid: true
      end
      route_param :id do
        delete do
          authenticate!
          comment = Comment.find(params[:id])
          forbidden! if comment.user_id != current_user.id
          comment.destroy!
          empty_body!
        end
      end

      # GET /comments/:id/votes
      desc "Returns the comment votes"
      paginate per_page: PAGE_SIZE
      params do
        requires :id, type: String, desc: "Comment id.", uuid: true
      end
      route_param :id do
        get :votes, each_serializer: VoteCommentSerializer do
          authenticate!
          paginate Comment.find(params[:id]).votes.recent
        end
      end

      # POST /comments/:id/votes
      desc "Cast a vote to the comment"
      params do
        requires :id, type: String, desc: "Comment id.", uuid: true
        optional :kind, type: String, values: %w(up down), default: "up",
                        desc: "Vote kind can be up or down. Default is up."
      end
      route_param :id do
        post :votes, serializer: VoteCommentSerializer do
          authenticate! && authorize!(:vote, Comment)
          Comment.find(params[:id]).vote_by!(current_user, kind: params[:kind])
        end
      end
    end
  end
end
