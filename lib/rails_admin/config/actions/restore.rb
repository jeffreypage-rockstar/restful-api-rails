require "rails_admin/config/actions"
require "rails_admin/config/actions/base"

module RailsAdmin
  module Config
    module Actions
      class Restore < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :link_icon do
          "icon-ok"
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          Proc.new do
            if request.get?
              @object.restore
            end
            if request.post?
              @abstract_model.model.restore(params[:bulk_ids])
            end

            flash[:success] = t("admin.flash.successful",
                                name: @model_config.label,
                                action: t("admin.actions.restore.done"))
            redirect_to back_or_index
          end
        end
      end
    end
  end
end
