module Hyper
  # endpoints to get unread notifications, and mark them as read
  class Notifications < Base
    PAGE_SIZE = 30

    resource :notifications do
      # DELETE /notifications/seen
      desc "Mark all user notifications as seen"
      params do
        requires :before_id, type: String,
                             desc: "Latest notification id.",
                             uuid: true
      end
      delete :seen do
        authenticate!
        last_notification = Notification.find(params[:before_id])
        Notification.mark_all_as_seen(current_user.id, last_notification)
        empty_body!
      end

      # DELETE /notifications/read
      desc "Mark all user notifications as read"
      params do
        requires :before_id, type: String,
                             desc: "Latest notification id.",
                             uuid: true
      end
      delete :read do
        authenticate!
        last_notification = Notification.find(params[:before_id])
        Notification.mark_all_as_read(current_user.id, last_notification)
        empty_body!
      end

      # DELETE /notifications/:id
      desc "Mark a single user notification as read"
      params do
        requires :id, type: String, desc: "Notification id."
      end
      route_param :id do
        delete do
          authenticate!
          notification = current_user.notifications.find(params[:id])
          notification.mask_as_read!
          empty_body!
        end
      end

      # GET /notifications
      desc "Returns the user unread notifications list, paginated."
      paginate per_page: PAGE_SIZE
      get do
        authenticate!
        header "TotalUnseen", current_user.notifications.unseen.count.to_s
        paginate current_user.notifications.recent
      end
    end
  end
end
