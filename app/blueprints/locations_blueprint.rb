# frozen_string_literal: true

class LocationsBlueprint < Blueprinter::Base
  identifier :id

  fields :ip_address, :url, :longitude, :latitude
end
