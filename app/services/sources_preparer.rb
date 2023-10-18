# frozen_string_literal: true

class SourcesPreparer
  attr_accessor :type, :location, :source

  def self.call(type, source, location)
    new(type, source, location).call
  end

  def initialize(type, source, location)
    @type = type
    @source = source
    @location = location
  end

  def call
    case type
    when 'url'
      location.url = source
      location.ip_address = find_ip_with_url
    when 'ip_address'
      location.ip_address = source
    end
  end

  private

  def find_ip_with_url
    source.gsub!('www.', 'https://') if source.starts_with?('www.')

    prepared_url = URI.parse(source).host

    IPSocket.getaddress(prepared_url)
  end
end
