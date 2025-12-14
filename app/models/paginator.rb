class Paginator
  PER_PAGE = 15
  attr_reader :items, :page, :per_page, :total_pages

  def initialize(scope, page:)
    @items = scope
    @per_page = PER_PAGE
    @page = valid_page(page)
  end

  def paginated
    items.offset((page - 1) * per_page).limit(per_page)
  end

  def valid_page(page_param)
    p = page_param.to_i
    p = 1 if p < 1

    total_count = items.count
    @total_pages = (total_count / per_page.to_f).ceil
    @total_pages = 1 if @total_pages.zero?

    # Si la página actual NO EXISTE (por ejemplo después de eliminar)
    p = @total_pages if p > @total_pages

    p
  end
end
