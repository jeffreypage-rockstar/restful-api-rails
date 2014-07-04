if defined? RailsAdmin
  RailsAdmin.config do |config|

    ### Popular gems integration

    ## == Devise ==
    # config.authenticate_with do
    #   warden.authenticate! scope: :user
    # end
    # config.current_user_method(&:current_user)

    ## == Cancan ==
    # config.authorize_with :cancan

    ## == PaperTrail ==
    # config.audit_with :paper_trail, 'User',
    # 'PaperTrail::Version' # PaperTrail >= 3.0.0

    ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

    config.actions do
      dashboard                     # mandatory
      index                         # mandatory
      new do
        except ["User"]
      end
      bulk_delete
      show
      edit
      delete

      ## With an audit adapter, you can add:
      # history_index
      # history_show
    end
    config.included_models = ["Admin", "User", "Stack"]

    config.authenticate_with do
      warden.authenticate! scope: :admin
    end
    config.current_user_method(&:current_admin)
    config.model "User" do
      list do
        field :email
        field :username
        field :last_sign_in_at
        field :confirmed_at
      end
      edit do
        field :email
        field :password
        field :password_confirmation
        field :username
        field :facebook_token
        field :facebook_id
      end
      show do
        field :email
        field :password
        field :password_confirmation
        field :username
        field :facebook_token
        field :facebook_id
      end
    end

    config.model "Stack" do
      list do
        field :name
        field :description
        field :user do
          pretty_value do
            value.username
          end
        end
        field :protected
      end
      show do
        field :name
        field :description
        field :user do
          pretty_value do
            value.username
          end
        end
        field :protected
      end
      edit do
        field :name
        field :description
        field :user  do
          pretty_value do
            value.username
          end
        end
        field :protected
      end
    end
  end

  module RailsAdmin
    module Config
      module Fields
        module Types
          class Uuid < RailsAdmin::Config::Fields::Base
            RailsAdmin::Config::Fields::Types::register(self)
          end
        end
      end
    end
  end
end
