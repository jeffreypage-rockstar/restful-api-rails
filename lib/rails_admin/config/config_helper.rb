module RailsAdmin
  class ConfigHelper
    include Singleton

    def lookup_link(model_name, field_name)
      Proc.new do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: model_name,
            f: { field_name => { "0001" => { v: bindings[:object].id } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
    end

    def comments_count_field
      lookup_link("comment", :card_id)
    end

    def score_field
      lookup_link("vote", :votable_id)
    end

    def flags_count_field
      lookup_link("flag", :flaggable_id)
    end

    def devices_count_field
      Proc.new do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "device",
            f: { user: { "0001" => { v: bindings[:object].username } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
    end

    def networks_field
      Proc.new do
        pretty_value do
          value.map do |network|
            "<span class=\"label label-default\">#{network.provider}</span>"
          end.join(" ").html_safe
        end
      end
    end
  end
end
