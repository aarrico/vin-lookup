module Api
  module V1
    class VehiclesController < BaseController
      def show
        return render_invalid_vin unless Vin.valid?(params[:vin])

        vehicle_data = VinLookupService.call(params[:vin])
        inventory = DealerInventory.find_by(dealer: @current_dealer, vin: params[:vin])
        presented = VehiclePresenter.new(vehicle_data, @current_dealer, inventory: inventory).present

        render json: presented
      rescue NhtsaService::NotFoundError
        render json: { error: "VIN not found" }, status: :not_found
      rescue NhtsaService::Error => e
        render json: { error: "Vehicle data unavailable: #{e.message}" }, status: :bad_gateway
      end

      private

      def render_invalid_vin
        render json: { error: "Invalid VIN format" }, status: :unprocessable_content
      end
    end
  end
end
