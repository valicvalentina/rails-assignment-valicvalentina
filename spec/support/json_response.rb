module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end
  end
end
