# frozen_string_literal: true

class Pagination
  DEFAULT_PAGE_NUMBER = 1
  DEFAULT_PAGE_SIZE = 10

  attr_reader :scope, :pagination_params

  def initialize(pagination_params, scope)
    @pagination_params = pagination_params
    @scope = scope
  end

  def paginated_scope
    scope.limit(per_page).offset((page - 1) * per_page)
  end

  def pagination_data
    {
      total_pages: (scope.length.to_f / per_page).ceil,
      total_count: scope.length
    }
  end

  private

  def scope_length
    @scope_length ||= scope.length
  end

  def page
    @page ||= (pagination_params[:page] || DEFAULT_PAGE_NUMBER).to_i
  end

  def per_page
    @per_page ||= (pagination_params[:per_page] || DEFAULT_PAGE_SIZE).to_i
  end
end
