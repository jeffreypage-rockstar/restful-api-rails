module Validation
  class Uuid < Grape::Validations::Validator
    UUID_REGEX = /^[\da-f]{8}-?([\da-f]{4}-?){3}[\da-f]{12}$/i

    def validate_param!(attr_name, params)
      unless params[attr_name] =~ UUID_REGEX
        raise Grape::Exceptions::Validation, param: @scope.full_name(attr_name), message: 'must be in uuid format'
      end
    end
  end
end
