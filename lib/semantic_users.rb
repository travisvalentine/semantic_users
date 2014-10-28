require "semantic_users/version"
require "faraday"
require "hashie"
require "json"

module SemanticUsers
  def self.service
    @conn ||= Faraday.new(:url => "http://localhost:3001/") do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    @conn
  end

  def self.authenticate(email, password)
    params = { email: email, password: password }
    response = service.post("api/v1/authentications", params)
    parsed_response = parse_response(response)
    build_and_return_hashie(parsed_response)
  end

  def self.get(user_attribute, value)
    params = { attribute: user_attribute.to_s, value: value }
    response = service.get("api/v1/users", params)
    parsed_response = parse_response(response)
    build_and_return_hashie(parsed_response)
  end

  private

    def self.parse_response(response)
      if response.status == 200 || response.status == 201
        JSON.parse(response.body)
      else
        nil
      end
    end

    def self.build_and_return_hashie(response)
      Hashie::Mash.new(response)
    end
end
