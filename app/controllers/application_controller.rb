class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  SECRET_KEY = 'my_secret'.freeze

  def authenticate_request
    @headers = request.headers["Authorization"]

    @token = @headers.split(" ")&.last

    unless @token.present?
      return render json: { errors: ['token not found'] }, status: :not_found
    end

    @encoded_token = JWT.decode(@token, SECRET_KEY, true, { algorithm: 'HS256' })&.first

    Rails.logger.info "@encoded_token #{@encoded_token}"

    @revoked_token = RevokedToken.find_by(jti: @encoded_token["jti"])

    if @revoked_token.present?
      return render json: { errors: ['token revoked'] }, status: :not_found
    end

    @customer = Customer.find_by(email: @encoded_token["email"])

    unless @customer.present?
      return render json: { errors: ['user removed or locked'] }, status: :not_found
    end

    Current.customer = @customer
    Current.jwt = @encoded_token
  rescue
    render json: { errors: ['unauthorized'] }, status: :not_found
  end
end
