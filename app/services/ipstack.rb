# frozen_string_literal: true

class Ipstack
  ACCESS_KEY = ENV['IPSTACK_ACCESS_KEY']

  include HTTParty

  base_uri 'http://api.ipstack.com'

  attr_reader :ip

  def initialize(ip)
    @ip = ip
  end

  def find_location
    return unless response.success? && coordinates_present?

    parsed_response = JSON.parse(response.body)

    {
      latitude: parsed_response['latitude'],
      longitude: parsed_response['longitude']
    }
  end

  def response
    @response ||= self.class.get("/#{ip}", query: { access_key: ACCESS_KEY }, timeout: 5)
  end

  def coordinates_present?
    response[:latitude] && response[:longitude]
  end
end
