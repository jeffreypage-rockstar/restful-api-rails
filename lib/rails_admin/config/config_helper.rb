module RailsAdmin
  class ConfigHelper
    def comments_count_field
      Proc.new do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "comment",
            f: { card_id: { "0001" => { v: bindings[:object].id } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
    end

    def score_field
      Proc.new do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "vote",
            f: { votable_id: { "0001" => { v: bindings[:object].id } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
    end

    def flags_count_field
      Proc.new do
        pretty_value do
          path = bindings[:view].rails_admin.index_path(
            model_name: "flag",
            f: { flaggable_id: { "0001" => { v: bindings[:object].id } } }
          )
          bindings[:view].link_to(value, path).html_safe
        end
      end
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
