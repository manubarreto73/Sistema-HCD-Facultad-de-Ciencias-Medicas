class ExpedientsFilter
  attr_reader :scope, :params

  def initialize(scope, params)
    @scope  = scope
    @params = params
  end

  def call
    # Tipo de expediente
    result = scope
    # FIXME: ¿qué arranque o que contenga?
    result = result.where('file_number LIKE ?', "%#{@params[:file_number]}%") if @params[:file_number].present?
    result = result.where(destination_id: @params[:destination_id]) if @params[:destination_id].present?
    result = result.where(subject_id: @params[:subject_id]) if @params[:subject_id].present?
    result = result.where('creation_date >= ?', @params[:from_date]) if @params[:from_date].present?
    result = result.where('creation_date <= ?', @params[:to_date]) if @params[:to_date].present?

    @params[:treated].to_s == 'true' ? result.treated : result.no_treated
  end
end
