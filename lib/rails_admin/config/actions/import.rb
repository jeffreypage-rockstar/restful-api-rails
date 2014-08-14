module RailsAdmin
  module Config
    module Actions
      class Import < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          proc do
            if request.get? # NEW
              @object = @abstract_model.new
              # renders the form to upload the file
              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.post? # CREATE
              # calls the import method of the class
              @modified_assoc = []
              satisfy_strong_params!
              sanitize_params_for!(request.xhr? ? :modal : :create)

              @objects = []
              file = params[:file]
              if file && @authorization_adapter.try(:authorize,
                                                    :import,
                                                    @abstract_model)
                @objects = @abstract_model.model.import_csv(file.tempfile)
              end

              if @objects.any?
                respond_to do |format|
                  format.html { redirect_to_on_success }
                end
              else
                flash[:error] = t("admin.flash.error",
                                  name: @model_config.label.pluralize,
                                  action: t("admin.actions.import.done"))
                redirect_to back_or_index
              end

            end

          end
        end

        register_instance_option :link_icon do
          "icon-upload"
        end
      end
    end
  end
end
