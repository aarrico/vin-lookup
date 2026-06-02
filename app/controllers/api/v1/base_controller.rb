module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_dealer!

      private

      def authenticate_dealer!
        key = request.headers["X-Dealer-API-Key"]
        @current_dealer = Dealer.find_by(api_key: key)
        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_dealer
      end
    end
  end
end
