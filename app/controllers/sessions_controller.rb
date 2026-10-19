class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:login, :logout]
  before_action :authenticate_request, only: [:logout]

  def login
    @customer = Customer.authenticate_by(email: login_params["email"], password: login_params["password"])

    Rails.logger.info "logger #{login_params}"

    unless @customer.present?
      return render json: { errors: ['login failed'] }, status: :not_found
    end

    @payload = {
      jti: SecureRandom.uuid,
      email: @customer.email,
      exp: 24.hours.from_now.to_i
    }

    @decoded = JWT.encode(@payload, SECRET_KEY, 'HS256')

    render json: { token: @decoded }, status: :ok
  end

  def logout
    @jti = Current.jwt["jti"]
    revoked_token = RevokedToken.new({
      jti: @jti
    })

    revoked_token.save

    render json: { message: ['logout successfully'] }, status: :ok
  end

  private

  def login_params
    params.require(:data).permit(:email, :password)
  end
end
