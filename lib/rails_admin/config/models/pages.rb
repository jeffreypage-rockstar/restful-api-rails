RailsAdmin.config do |config|
  config.model "Page" do
    list do
      field :title
      field :slug
      field :content
      field :created_at do
        filterable true
      end
      sort_by :created_at
    end
    show do
      field :title
      field :slug do
        pretty_value do
          path = bindings[:view].main_app.static_url(bindings[:object])
          [
            bindings[:view].link_to(value, path, target: "_blank"),
            '<span class="label label-default">link to public page</span>'
          ].join(" ").html_safe
        end
      end
      field :content do
        pretty_value do
          %{<div class="content">
              #{value}
            </div >}.html_safe
        end
      end
      field :created_at
    end
    edit do
      field :title
      field :slug do
        required false
        help "Optional. Leave it blank to auto generate a page slug."
      end
      field :content, :wysihtml5
    end
  end
end
