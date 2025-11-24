module ApplicationHelper
  def error_class(resource, field)
    puts 'Entró al error class'
    resource.errors[field].any? ? "border-red-500 ring-red-200 focus:border-red-600" : ""
  end
end
