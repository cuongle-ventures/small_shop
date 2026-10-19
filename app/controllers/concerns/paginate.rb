module Paginate
  extend ActiveSupport::Concern

  class_methods do
    def paginate params
      page = params["page"].to_i
      per_page = params["per_page"].to_i
      sort_column = params.fetch("sort_column", :id)
      direction = params.fetch("direction", :asc)
      query = params["query"]

      scope = self

      if per_page < 1
        raise PaginateError.new("per_page is zero")
      end

      if query.present?
        scope = scope.where("name like '%#{query}%'")
      end

      total = scope.count
      total_page = (total.to_f / per_page).ceil

      if page > total_page && page > 1
        raise PaginateError.new("out of bounary")
      end

      items = scope.offset((page - 1) * per_page).limit(per_page).order(sort_column => direction)

      metadata = {
        page: page,
        per_page: per_page,
        sort_column: sort_column,
        direction: direction,
        total: total,
        total_page: total_page
      }
      {
        items: items,
        metadata: metadata,
      }
    end
  end
end