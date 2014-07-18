module Hyper
  # endpoints to get unread notifications, and mark them as read
  class Notifications < Base
    PAGE_SIZE = 30

    resource :notifications do
      # POST /notifications
      desc "Mark all user notifications as read"
      post do
        authenticate!
        Notification.mark_all_as_read(current_user.id)
        empty_body!
      end

      # GET /notifications
      desc "Returns the user unread notifications list, paginated."
      paginate per_page: PAGE_SIZE
      get do
        authenticate!
        paginate current_user.notifications.unread
      end
    end
  end
end
