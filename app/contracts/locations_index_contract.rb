# frozen_string_literal: true

class LocationsIndexContract < Dry::Validation::Contract
  params do
    optional(:page).filled(:integer, gteq?: 1)
    optional(:per_page).filled(:integer, gteq?: 1)
  end
end
