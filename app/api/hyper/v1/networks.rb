module Hyper
  module V1
    # api to manage current user networks
    class Networks < Base
      PAGE_SIZE = 30

      resource :networks do
        # POST /networks
        desc "Associate the user to a social network"
        params do
          requires :provider, type: String, desc: "Network provider name"
          requires :uid, type: String, desc: "User uid for this network"
          requires :token, type: String, desc: "User token for this network"
          optional :secret, type: String, desc: "User secret for this network"
        end
        post do
          authenticate!
          network = NetworkRegisterService.
                      new(current_user, params[:provider]).
                      register!(permitted_params)
          header "Location", "/networks/#{network.provider}"
          network
        end

        # GET /networks
        desc "Returns the user networks list"
        get do
          authenticate!
          current_user.networks
        end

        # GET /networks/providers
        desc "Returns the acceptable providers list"
        get :providers do
          authenticate!
          Network::PROVIDERS
        end

        # GET /networks/:provider
        desc "Returns the user network details"
        params do
          requires :provider, type: String, desc: "Network provider. "\
                                                  "ex: twitter"
        end
        route_param :provider do
          get do
            authenticate!
            provider = params[:provider].to_s.downcase
            current_user.networks.find_by!(provider: provider)
          end
        end

        # PUT /networks/:provider
        desc "Update a user network details"
        params do
          requires :provider, type: String, desc: "Network provider. "\
                                                  "ex: twitter"
          optional :uid, type: String, desc: "User uid for this network"
          optional :token, type: String, desc: "User token for this network"
          optional :secret, type: String, desc: "User secret for this network"
        end
        route_param :provider do
          put do
            authenticate!
            NetworkRegisterService.
              new(current_user, params[:provider]).
              update!(permitted_params)
          end
        end

        # DELETE /networks/:provider
        desc "De-associate current user from the network"
        params do
          requires :provider, type: String, desc: "Network provider. "\
                                                  "ex: twitter"
        end
        route_param :provider do
          delete do
            authenticate!
            provider = params[:provider].to_s.downcase
            network = current_user.networks.find_by!(provider: provider)
            network.destroy!
            empty_body!
          end
        end
      end
    end
  end
end
