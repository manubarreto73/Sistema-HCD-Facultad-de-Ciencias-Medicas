class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.errors.any?
        flash.now[:alert] = "No se ha podido crear la cuenta, intente nuevamente y preste atención a las recomendaciones"
      end
    end
  end
end