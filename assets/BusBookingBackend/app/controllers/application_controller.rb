class ApplicationController < ActionController::API
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    if token.nil?
      render json: { error: 'No token provided' }, status: :unauthorized and return
    end

    begin
      decoded = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, algorithm: 'HS256')
      user_id = decoded[0]['sub']
      @current_user = User.find(user_id)
    rescue JWT::ExpiredSignature
      render json: { error: 'Token expired' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end