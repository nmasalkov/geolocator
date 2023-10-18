# frozen_string_literal: true

class LocationsFindContract < Dry::Validation::Contract
  params do
    required(:search_string).filled(:string)
  end
end
