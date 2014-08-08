module Searchkick
  # original Searchkick::Query class does not support scroll param
  class QueryWithScroll < Query
    def params
      params = super
      params.merge!(scroll: options[:scroll]) if options[:scroll]
      params
    end
  end
end