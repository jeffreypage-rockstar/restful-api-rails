if defined? RailsAdmin
  require "admin_restore"

  RailsAdmin.config do |config|

    ### Popular gems integration

    ## == Devise ==
    # config.authenticate_with do
    #   warden.authenticate! scope: :user
    # end
    # config.current_user_method(&:current_user)

    ## == Cancan ==
    config.authorize_with :cancan, AdminAbility
    # config.authorize_with :cancan

    ## == PaperTrail ==
    # config.audit_with :paper_trail, 'User',
    # 'PaperTrail::Version' # PaperTrail >= 3.0.0

    ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

    config.main_app_name = ["Hyper"]

    config.actions do
      dashboard                     # mandatory
      index                         # mandatory
      new do
        except ["User", "Setting", "Activity", "Notification"]
      end
      bulk_delete do
        except ["DeletedUser", "Setting", "Activity", "Notification"]
      end
      show
      edit do
        except ["Activity", "Notification"]
      end
      delete do
        except ["DeletedUser", "Setting", "Activity", "Notification"]
      end
      restore do
        only ["DeletedUser"]
      end
      ## With an audit adapter, you can add:
      # history_index
      # history_show
    end
    config.included_models = %w(Admin User DeletedUser Stack Card Comment
                                Reputation Setting Activity Notification)

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
        field :username
        field :facebook_token
        field :facebook_id
      end
      show do
        field :email
        field :username
        field :facebook_token
        field :facebook_id
      end
    end

    config.model "DeletedUser" do
      list do
        field :email
        field :username
        field :last_sign_in_at
        field :deleted_at
      end
      show do
        field :email
        field :username
        field :facebook_token
        field :facebook_id
      end
      edit do
        field :email
        field :username
        field :facebook_token
        field :facebook_id
      end
    end

    config.model "Stack" do
      list do
        field :display_name
        field :description
        field :user do
          pretty_value do
            value.try(:username)
          end
        end
        field :protected
        field :cards
      end
      show do
        field :display_name
        field :description
        field :user do
          pretty_value do
            value.try(:username)
          end
        end
        field :protected
      end
      edit do
        field :name
        field :description
        field :user  do
          pretty_value do
            value.try(:username)
          end
        end
        field :protected
      end
    end

    config.model "Card" do
      list do
        field :name
        field :description
        field :user
        field :score
        field :stack
        field :comments
        field :created_at
      end
      show do
        field :name
        field :description
        field :user
        field :score
        field :stack
        field :comments
        field :created_at
      end
      edit do
        field :name
        field :description
        field :user
        field :stack
        field :score do
          read_only true
        end
      end
    end

    config.model "Comment" do
      list do
        field :body
        field :score
        field :replying
        field :card
        field :user
        field :created_at
      end
      show do
        field :body
        field :score
        field :replying
        field :card
        field :user
        field :created_at
      end
      edit do
        field :body
        field :score do
          read_only true
        end
        field :replying
        field :card
        field :user
        field :created_at
      end
    end

    config.model "Reputation" do
      list do
        field :name
        field :min_score
      end
    end

    config.model "Setting" do
      list do
        field :name do
          label "Setting"
        end
        field :value
        field :description
      end

      edit do
        field :name do
          label "Setting"
          read_only true
        end
        field :value
        field :description do
          read_only true
        end
      end
    end

    config.model "Activity" do
      list do
        field :key do
          pretty_value do
            case value
            when /\.destroy/
              %{<span class='label label-warning'>#{value}</span>}
            else
              %{<span class='label label-default'>#{value}</span>}
            end.html_safe
          end
        end
        field :trackable
        field :owner
        field :notified
        field :created_at
      end

      show do
        field :key
        field :trackable
        field :owner
        field :notified
        field :created_at
      end
    end

    config.model "Notification" do
      list do
        field :senders do
          formatted_value do
            value.map do |username, user_id|
              path = bindings[:view].rails_admin.show_path(model_name: "user", id: user_id)
              bindings[:view].link_to(username, path)
            end.join(", ").html_safe
          end
        end
        field :caption
        field :user
        field :subject
        field :sent_at
        field :seen?, :boolean
        field :read?, :boolean
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
