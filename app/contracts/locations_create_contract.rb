# frozen_string_literal: true

class LocationsCreateContract < Dry::Validation::Contract
  VALID_URL_SCHEMES = %w[http https].freeze
  VALID_TYPES = %w[url ip_address].freeze

  params do
    required(:source).filled(:string)
    required(:type).filled(:string, included_in?: VALID_TYPES)
  end

  rule(:source) do
    case values['type']
    when 'url'
      validate_url(key, value)
    when 'ip_address'
      validate_ip(key, value)
    end
  end

  def validate_ip(key, value)
    key.failure('IP is invalid') unless valid_ip?(value)
  end

  def valid_ip?(value)
    IPAddr.new(value)
    true
  rescue IPAddr::InvalidAddressError
    false
  end

  def validate_url(key, value)
    value.gsub!('www.', 'https://') if value.starts_with?('www.')

    key.failure('We could not parse your url. Please check that the link is valid') unless valid_url?(value)
  end

  def valid_url?(value)
    uri = URI.parse(value)
    VALID_URL_SCHEMES.include?(uri.scheme) && uri.host
  rescue URI::InvalidURIError
    false
  end
end
