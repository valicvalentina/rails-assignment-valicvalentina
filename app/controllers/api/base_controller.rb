module Api
  class BaseController < ApplicationController
    def set_serializer
      if action_name == 'show' && request.headers['X-API-SERIALIZER'] == 'fast_jsonapi'
        return @serializer = "FastJsonapi::#{serializer_name}".constantize
      end

      @serializer = serializer_name
    end

    def serialize(resource, view)
      if @serializer == "FastJsonapi::#{serializer_name}".constantize
        @serializer.new(resource).serializable_hash
      else
        @serializer.render_as_json(resource, view: view)
      end
    end

    def serializer_name
      "#{controller_name.capitalize.singularize}Serializer".constantize
    end
  end
end
