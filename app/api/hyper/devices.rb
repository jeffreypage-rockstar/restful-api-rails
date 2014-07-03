module Hyper
  # api to create a user and/or get the current user data
  class Devices < Base
    PAGE_SIZE = 30

    resources :devices do
      # GET /devices
      desc "Returns the current user registered devices, paginated"
      paginate per_page: PAGE_SIZE
      get do
        authenticate!
        paginate current_user.devices.recent
      end

      # PUT /devices/:id
      desc "Updates the user device push_token"
      params do
        requires :id, type: String, desc: "Device id", uuid: true
        requires :push_token, type: String,
                              desc: "Device token for push notifications"
      end
      route_param :id do
        put do
          authenticate!
          device = Device.find(params[:id])
          forbidden! if device.user_id != current_user.id
          device.update_attributes!(permitted_params)
          empty_body!
        end
      end

      # DELETE /devices/:id
      desc "Deletes a user device"
      params do
        requires :id, type: String, desc: "Device id", uuid: true
      end
      route_param :id do
        delete do
          authenticate!
          device = Device.find(params[:id])
          forbidden! if device.user_id != current_user.id
          device.destroy!
          empty_body!
        end
      end
    end
  end
end
