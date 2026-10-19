module Params
  def paginate_params
    params.permit(:page, :per_page, :sort_column, :direction, :query)
  end
end