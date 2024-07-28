module TestHelpers
  module JsonResponse
    def json_body
      JSON.parse(response.body)
    end
  end

  module Headers
    def valid_headers(user)
      { 'Authorization' => user.token }
    end

    def invalid_headers
      { 'Authorization' => 'Bearer invalid_token' }
    end
  end
end
