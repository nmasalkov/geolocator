# frozen_string_literal: true

class Location < ApplicationRecord
  validates :url, uniqueness: true
  validates :ip_address, uniqueness: true

  def longitude
    geolocation.y
  end

  def latitude
    geolocation.x
  end
end
