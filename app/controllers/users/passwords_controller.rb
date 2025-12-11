class Users::PasswordsController < Devise::PasswordsController

  # POST /users/password
  def create
    user = User.find_by(email: params[:user][:email])

    if user.present?
      new_password = generate_reset_password
      user.update(password: new_password)

      UserMailer.reset_password_email(user, new_password).deliver_now
    end

    redirect_to new_user_session_path, notice: "Si el correo es válido, se envió una nueva contraseña."
  end

  private

  def generate_reset_password
    # Debe cumplir tu regex: mayúscula + número + longitud 8–16
    letters = ("a".."z").to_a + ("A".."Z").to_a
    numbers = ("0".."9").to_a

    must_have = [
      ("A".."Z").to_a.sample, # Una mayúscula
      numbers.sample          # Un número
    ]

    rest = Array.new(8) { (letters + numbers).sample }  # Completa → total 10 caracteres

    (must_have + rest).shuffle.join
  end
end
