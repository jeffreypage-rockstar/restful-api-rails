module Validation
  class Uuid < Grape::Validations::Validator
    UUID_REGEX = /^[\da-f]{8}-?([\da-f]{4}-?){3}[\da-f]{12}$/i

    def validate_param!(attr_name, params)
      opt = {
        param: @scope.full_name(attr_name),
        message: "must be in uuid format"
      }
      valid = params[attr_name] =~ UUID_REGEX
      raise Grape::Exceptions::Validation, opt unless valid
    end
  end
end
