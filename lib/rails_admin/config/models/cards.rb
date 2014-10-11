helper = RailsAdmin::ConfigHelper.instance

RailsAdmin.config do |config|
  config.model "Card" do
    list do
      scopes [nil, :flagged]
      field :name
      field :stack do
        filterable false
      end
      field :stack_id, :lookup
      field :user
      field :source, :enum do
        enum { Card::SOURCES }
        searchable true
        queryable false
      end
      field :score, &helper.score_field
      field :flags_count, &helper.flags_count_field
      field :comments_count, &helper.comments_count_field
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
      field :score, &helper.score_field
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
      field :flags_count, &helper.flags_count_field
      field :comments_count, &helper.comments_count_field
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
end
