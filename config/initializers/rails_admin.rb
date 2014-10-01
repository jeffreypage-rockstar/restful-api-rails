if defined? RailsAdmin
  require "rails_admin/config/actions/restore"
  require "rails_admin/config/actions/import"
  require "rails_admin/config/config_helper"
  require "rails_admin/config/models/admins"
  require "rails_admin/config/models/users"
  require "rails_admin/config/models/deleted_users"
  require "rails_admin/config/models/stacks"
  require "rails_admin/config/models/subscriptions"
  require "rails_admin/config/models/cards"
  require "rails_admin/config/models/comments"
  require "rails_admin/config/models/devices"
  require "rails_admin/config/models/settings"
  require "rails_admin/config/models/votes"
  require "rails_admin/config/models/flags"
  require "rails_admin/config/models/reputations"
  require "rails_admin/config/models/activities"
  require "rails_admin/config/models/notifications"
  require "rails_admin/config/models/stats"
  require "rails_admin/config/models/stack_stats"
  require "admin_ability"

  RailsAdmin.config do |config|
    ## == Devise ==
    config.authenticate_with do
      warden.authenticate! scope: :admin
    end
    config.current_user_method(&:current_admin)

    ## == Cancan ==
    config.authorize_with :cancan, AdminAbility

    ## == PaperTrail ==
    # config.audit_with :paper_trail, 'User',
    # 'PaperTrail::Version' # PaperTrail >= 3.0.0

    ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

    config.main_app_name = ["Hyper"]

    config.actions do
      dashboard                     # mandatory
      index                         # mandatory
      new do
        except ["User", "Setting", "Activity", "Notification", "Flag", "Vote",
                "Device", "Stats", "StackStats"]
      end
      import do
        only ["Stack"]
      end
      bulk_delete do
        except ["DeletedUser", "Setting", "Activity", "Notification", "Stats",
                "StackStats"]
      end
      show do
        except ["Stats", "StackStats"]
      end
      edit do
        except ["Activity", "Notification", "Device", "Stats", "StackStats"]
      end
      delete do
        except ["DeletedUser", "Setting", "Activity", "Notification", "Stats",
                "StackStats"]
      end
      restore do
        only ["DeletedUser"]
      end
      ## With an audit adapter, you can add:
      # history_index
      # history_show
    end
    config.included_models = %w(Admin User DeletedUser Stack Card Comment
                                Flag Vote Reputation Setting Activity
                                Notification Subscription Device Stats
                                StackStats)

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
