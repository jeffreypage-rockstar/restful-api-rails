if defined? RailsAdmin
  require "rails_admin/config/actions/restore"
  require "rails_admin/config/actions/import"
  require "admin_ability"

  RailsAdmin.config do |config|

    ### Popular gems integration

    ## == Devise ==
    # config.authenticate_with do
    #   warden.authenticate! scope: :user
    # end
    # config.current_user_method(&:current_user)

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
                "Device", "Stats"]
      end
      import do
        only ["Stack"]
      end
      bulk_delete do
        except ["DeletedUser", "Setting", "Activity", "Notification", "Stats"]
      end
      show do
        except ["Stats"]
      end
      edit do
        except ["Activity", "Notification", "Device", "Stats"]
      end
      delete do
        except ["DeletedUser", "Setting", "Activity", "Notification", "Stats"]
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
                                Notification Subscription Device Stats)

    config.authenticate_with do
      warden.authenticate! scope: :admin
    end
    config.current_user_method(&:current_admin)

    flags_count_field = Proc.new do
      pretty_value do
        path = bindings[:view].rails_admin.index_path(
          model_name: "flag",
          f: { flaggable_id: { "0001" => { v: bindings[:object].id } } }
        )
        bindings[:view].link_to(value, path).html_safe
      end
    end

    devices_count_field = Proc.new do
      pretty_value do
        path = bindings[:view].rails_admin.index_path(
          model_name: "device",
          f: { user: { "0001" => { v: bindings[:object].username } } }
        )
        bindings[:view].link_to(value, path).html_safe
      end
    end

    networks_field = Proc.new do
      pretty_value do
        value.map do |network|
          "<span class=\"label label-default\">#{network.provider}</span>"
        end.join(" ").html_safe
      end
    end

    config.model "User" do
      object_label_method :username
      list do
        scopes [nil, :flagged, :signup_with_facebook]
        field :email
        field :username
        field :location
        field :score
        field :fb_signup?, :boolean
        field :last_sign_in_at do
          filterable true
        end
        field :flags_count, &flags_count_field
        field :confirmed_at
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end
      edit do
        field :email
        field :username
        field :location
        field :bio
        field :facebook_token
        field :facebook_id
      end
      show do
        field :email
        field :username
        field :location
        field :score
        field :bio
        field :stacks_count do
          pretty_value do
            path = bindings[:view].rails_admin.index_path(
              model_name: "stack",
              f: { user: { "0001" => { v: bindings[:object].username } } }
            )
            bindings[:view].link_to(value, path).html_safe
          end
        end
        field :cards_count do
          pretty_value do
            path = bindings[:view].rails_admin.index_path(
              model_name: "card",
              f: { user: { "0001" => { v: bindings[:object].username } } }
            )
            bindings[:view].link_to(value, path).html_safe
          end
        end
        field :comments_count do
          pretty_value do
            path = bindings[:view].rails_admin.index_path(
              model_name: "comment",
              f: { user: { "0001" => { v: bindings[:object].username } } }
            )
            bindings[:view].link_to(value, path).html_safe
          end
        end
        field :flags_count, &flags_count_field
        field :devices_count, &devices_count_field
        field :last_sign_in_at
        field :confirmed_at
        field :networks, &networks_field
        field :created_at
      end
    end

    config.model "DeletedUser" do
      object_label_method :username
      list do
        scopes [nil, :flagged, :signup_with_facebook]
        field :email
        field :username
        field :location
        field :score
        field :fb_signup?, :boolean
        field :last_sign_in_at do
          filterable true
        end
        field :flags_count, &flags_count_field
        field :confirmed_at
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end
      show do
        field :email
        field :username
        field :location
        field :score
        field :bio
        field :flags_count, &flags_count_field
        field :last_sign_in_at
        field :confirmed_at
        field :created_at
      end
      edit do
        field :email
        field :username
        field :location
        field :facebook_token
        field :facebook_id
      end
    end

    config.model "Device" do
      list do
        scopes [nil, :accepting_notification]
        field :user
        field :device_type
        field :push_token
        field :accept_notification?, :boolean
        field :last_sign_in_at do
          filterable true
        end
        field :created_at do
          filterable true
        end
        sort_by :last_sign_in_at
      end
      show do
        field :user
        field :device_type
        field :push_token
        field :sns_arn
        field :last_sign_in_at
        field :created_at
      end
      edit do
        field :user
        field :device_type
        field :push_token
        field :sns_arn
      end
    end

    stack_subscriptions_count_field = Proc.new do
      pretty_value do
        path = bindings[:view].rails_admin.index_path(
          model_name: "subscription",
          f: { stack_id: { "0001" => { v: bindings[:object].id } } }
        )
        bindings[:view].link_to(value, path).html_safe
      end
    end

    config.model "Stack" do
      list do
        field :display_name
        field :name do
          visible false
          searchable true
        end
        field :description
        field :user
        field :protected
        field :subscriptions_count, &stack_subscriptions_count_field
        field :cards
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end
      show do
        field :display_name
        field :description
        field :user
        field :protected
        field :subscriptions_count, &stack_subscriptions_count_field
        field :cards
      end
      edit do
        field :name
        field :description
        field :user
        field :protected
      end
    end

    config.model "Subscription" do
      list do
        field :user
        field :stack
        field :stack_id, :enum do
          enum do
            Stack.recent.limit(10).map { |s| [s.name, s.id] }
          end
          visible false
          searchable true
          queryable false
        end
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end
      show do
        field :user
        field :stack
        field :created_at
      end
      edit do
        field :user
        field :stack
      end
    end

    comments_count_field = Proc.new do
      pretty_value do
        path = bindings[:view].rails_admin.index_path(
          model_name: "comment",
          f: { card_id: { "0001" => { v: bindings[:object].id } } }
        )
        bindings[:view].link_to(value, path).html_safe
      end
    end

    score_field = Proc.new do
      pretty_value do
        path = bindings[:view].rails_admin.index_path(
          model_name: "vote",
          f: { votable_id: { "0001" => { v: bindings[:object].id } } }
        )
        bindings[:view].link_to(value, path).html_safe
      end
    end

    config.model "Card" do
      list do
        scopes [nil, :flagged]
        field :name
        field :stack
        field :user
        field :source, :enum do
          enum { Card::SOURCES }
          searchable true
          queryable false
        end
        field :score, &score_field
        field :flags_count, &flags_count_field
        field :comments_count, &comments_count_field
        field :description
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end
      show do
        field :name do
          pretty_value do
            path = bindings[:view].main_app.card_url(bindings[:object])
            [
              bindings[:view].link_to(value, path, target: "_blank"),
              '<span class="label label-default">link to public page</span>'
            ].join(" ").html_safe
          end
        end
        field :description
        field :user
        field :source
        field :score, &score_field
        field :stack
        field :images do
          pretty_value do
            value.map do |image|
              %{<div class="thumbnail">
                  <img src="#{image.thumbnail_url}" width="160">
                  <div class="caption">#{image.caption}</div>
                </div>}
            end.join.html_safe
          end
        end
        field :comments_count, &comments_count_field
        field :created_at
      end
      edit do
        field :name
        field :description
        field :user
        field :stack
        field :source, :enum do
          enum { Card::SOURCES }
        end
        field :score do
          read_only true
        end
      end
    end

    config.model "Comment" do
      object_label_method :body
      list do
        scopes [nil, :flagged]
        field :body
        field :score, &score_field
        field :flags_count, &flags_count_field
        field :replying
        field :card
        field :card_id, :enum do
          enum do
            Card.newest.limit(10).map { |c| [c.name, c.id] }
          end
          visible false
          searchable true
          queryable false
        end
        field :user
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end
      show do
        field :body
        field :score, &score_field
        field :flags_count, &flags_count_field
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

    config.model "Flag" do
      list do
        field :flaggable
        field :flaggable_type, :enum do
          enum do
            ["User", "Card", "Comment"]
          end
          filterable true
        end
        field :flaggable_id, :enum do
          enum do
            []
          end
          visible false
          searchable true
          queryable false
        end
        field :user do
          filterable true
        end
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end

      show do
        field :flaggable
        field :flaggable_type
        field :user
        field :created_at
      end
    end

    config.model "Vote" do
      list do
        scopes [nil, :up_votes, :down_votes]
        field :votable
        field :votable_type do
          filterable true
        end
        field :flag
        field :votable_id, :enum do
          enum do
            []
          end
          visible false
          searchable true
          queryable false
        end
        field :user do
          filterable true
        end
        field :created_at do
          filterable true
        end
        sort_by :created_at
      end

      show do
        field :votable
        field :votable_type
        field :flag
        field :weight
        field :user
        field :created_at
      end

      edit do
        field :votable
        field :flag
        field :user
        field :weight
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
        field :name
        field :value
        field :description
      end

      edit do
        field :name do
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
        scopes [nil, :notified, :not_notified]
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
        field :created_at do
          filterable true
        end
        sort_by :created_at
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
        scopes [nil, :sent, :not_sent, :seen, :unseen]
        field :senders do
          formatted_value do
            (value || {}).map do |username, user_id|
              path = bindings[:view].rails_admin.
                                     show_path(model_name: "user", id: user_id)
              bindings[:view].link_to(username, path)
            end.join(", ").html_safe
          end
        end
        field :caption
        field :user
        field :subject
        field :created_at do
          filterable true
        end
        field :sent?, :boolean
        field :seen?, :boolean
        field :read?, :boolean
        field :sent_at do
          filterable true
        end
        sort_by :created_at
      end

      show do
        field :senders do
          formatted_value do
            (value || {}).map do |username, user_id|
              path = bindings[:view].rails_admin.
                                     show_path(model_name: "user", id: user_id)
              bindings[:view].link_to(username, path)
            end.join(", ").html_safe
          end
        end
        field :caption
        field :user
        field :subject
        field :created_at
        field :sent_at
        field :seen_at
        field :read_at
      end
    end

    stats_field_count = Proc.new do
      column_width 60
    end
    config.model "Stats" do
      list do
        scopes [:daily, :weekly, :monthly]
        field :period do
          sortable true
          sort_reverse true
        end
        field :date do
          visible false
          filterable true
        end
        field :users, &stats_field_count
        field :deleted_users, &stats_field_count
        field :stacks, &stats_field_count
        field :subscriptions, &stats_field_count
        field :cards, &stats_field_count
        field :comments, &stats_field_count
        field :flagged_users, &stats_field_count
        field :flagged_cards, &stats_field_count
        field :flagged_comments, &stats_field_count

        sort_by :period
        sort_without_tablename true
        items_per_page 100
        show_pagination false
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
