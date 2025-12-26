class PasswordChangesController < ApplicationController
  before_action :authenticate_user!

  def edit
  end

  def update
    if current_user.update(password_params)
      bypass_sign_in(current_user)
      flash[:notice] = "La contraseña se actualizó correctamente"
      redirect_to root_path, notice: "La contraseña fue actualizada correctamente."
    else
      flash.now[:alert] = "No se pudo actualizar la contraseña"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end