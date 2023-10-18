# frozen_string_literal: true

class LocationsController < ApplicationController
  def index
    if locations_index_contract.success?
      locations = LocationsBlueprint.render_as_hash(pagination.paginated_scope)

      render json: { locations: locations, pagination: pagination.pagination_data }
    else
      render json: { errors: locations_index_contract.errors.to_h }, status: :unprocessable_entity
    end
  end

  def show
    return render json: { errors: ['location not found'] }, status: :not_found unless location

    render json: LocationsBlueprint.render(location)
  end

  def create
    if locations_create_contract.success?
      creator = LocationCreator.new(params.permit(:source, :type).to_unsafe_hash)
      creator.call

      render json: { message: creator.message, location: creator.location }, status: creator.status
    else
      render json: { errors: locations_create_contract.errors.to_h }, status: :unprocessable_entity
    end
  end

  def destroy
    return render json: { errors: ['location not found'] }, status: :not_found unless location

    location.destroy

    render json: { message: 'Location deleted successfully' }
  end

  # task didn't include full text search, in that case, GIN indexing and search string sanitizing should be used
  def find
    if locations_find_contract.success?
      return render json: { errors: ['location not found'] }, status: :not_found unless searched_location

      render json: LocationsBlueprint.render(searched_location)
    else
      render json: { errors: locations_find_contract.errors.to_h }, status: :unprocessable_entity
    end
  end

  private

  def location
    @location ||= Location.find_by(params.permit(:id))
  end

  def searched_location
    @searched_location ||= match_location
  end

  def match_location
    search_string = params.permit(:search_string)[:search_string]

    Location.find_by(url: search_string) || Location.find_by(ip_address: search_string)
  end

  def locations_index_contract
    @locations_index_contract ||= LocationsIndexContract.new.call(params.to_unsafe_hash)
  end

  def locations_find_contract
    @locations_find_contract ||= LocationsFindContract.new.call(params.to_unsafe_hash)
  end

  def locations_create_contract
    @locations_create_contract ||= LocationsCreateContract.new.call(params.to_unsafe_hash)
  end

  def pagination
    @pagination ||= Pagination.new(params, Location.all)
  end

  def pagination_params
    params.permit(:page, :per_page)
  end
end
