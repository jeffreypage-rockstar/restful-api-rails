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
        except ["User", "Setting", "Activity", "Notification", "Flag", "Vote"]
      end
      import do
        only ["Stack"]
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
                                Flag Vote Reputation Setting Activity
                                Notification Subscription)

    config.authenticate_with do
      warden.authenticate! scope: :admin
    end
    config.current_user_method(&:current_admin)

    flags_count_field = Proc.new do
      label "Flags"
      pretty_value do
        path = bindings[:view].rails_admin.index_path(
          model_name: "flag",
          f: { flaggable_id: { "0001" => { v: bindings[:object].id } } }
        )
        bindings[:view].link_to(value, path).html_safe
      end
    end

    config.model "User" do
      object_label_method :username
      list do
        scopes [nil, :flagged]
        field :email
        field :username
        field :location
        field :score
        field :flags_count, &flags_count_field
        field :last_sign_in_at
        field :confirmed_at
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
        field :flags_count, &flags_count_field
        field :last_sign_in_at
        field :confirmed_at
      end
    end

    config.model "DeletedUser" do
      list do
        scopes [nil, :flagged]
        field :email
        field :username
        field :location
        field :score
        field :flags_count, &flags_count_field
        field :last_sign_in_at
        field :confirmed_at
      end
      show do
        field :email
        field :username
        field :location
        field :score
        field :flags_count, &flags_count_field
        field :last_sign_in_at
        field :confirmed_at
      end
      edit do
        field :email
        field :username
        field :location
        field :facebook_token
        field :facebook_id
      end
    end

    stack_subscriptions_count_field = Proc.new do
      label "Subscriptions"
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
          label "Stack Name"
          visible false
          searchable true
        end
        field :description
        field :user
        field :protected
        field :subscriptions_count, &stack_subscriptions_count_field
        field :cards
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
          label "For Stack"
          enum do
            Stack.recent.limit(10).map { |s| [s.name, s.id] }
          end
          visible false
          searchable true
          queryable false
        end
        field :created_at
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
      label "Comments"
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
        field :score, &score_field
        field :flags_count, &flags_count_field
        field :comments_count, &comments_count_field
        field :description
        field :created_at
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
        field :score, &score_field
        field :stack
        field :images do
          pretty_value do
            value.map do |image|
              %{<div class="thumbnail">
                  <img src="#{image.image_url}" width="160">
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
          label "For Card"
          enum do
            Card.newest.limit(10).map { |c| [c.name, c.id] }
          end
          visible false
          searchable true
          queryable false
        end
        field :user
        field :created_at
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
        field :flaggable do
          label "Flagged Item"
        end
        field :flaggable_type do
          label "Type"
          filterable true
        end
        field :flaggable_id, :enum do
          label "Flags For"
          enum do
            []
          end
          visible false
          searchable true
          queryable false
        end
        field :user do
          label "Flagged by"
          filterable true
        end
        field :created_at do
          label "Flagged at"
          filterable true
        end
        sort_by :created_at
      end

      show do
        field :flaggable do
          label "Flagged Item"
        end
        field :flaggable_type do
          label "Type"
          filterable true
        end
        field :user do
          label "Flagged by"
          filterable true
        end
        field :created_at do
          label "Flagged at"
          filterable true
        end
      end
    end

    config.model "Vote" do
      list do
        scopes [nil, :up_votes, :down_votes]
        field :votable do
          label "Voted Item"
        end
        field :votable_type do
          label "Type"
          filterable true
        end
        field :flag do
          label "Up/Down"
        end
        field :votable_id, :enum do
          label "Votes For"
          enum do
            []
          end
          visible false
          searchable true
          queryable false
        end
        field :user do
          label "Voted by"
          filterable true
        end
        field :created_at do
          label "Voted at"
          filterable true
        end
        sort_by :created_at
      end

      show do
        field :votable do
          label "Voted Item"
        end
        field :votable_type do
          label "Type"
          filterable true
        end
        field :flag do
          label "Up/Down"
        end
        field :weight
        field :user do
          label "Voted by"
          filterable true
        end
        field :created_at do
          label "Voted at"
          filterable true
        end
      end

      edit do
        field :votable do
          label "Voted Item"
        end
        field :flag do
          label "up?"
        end
        field :user do
          label "Voted by"
        end
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
        field :created_at
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
        field :created_at
        field :sent?, :boolean
        field :seen?, :boolean
        field :read?, :boolean
        field :sent_at
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
