module Spree
  module Api
    module V1
      module Validators
        # Generate useful error messages for API calls to ReservedStockItemsController#reserve
        class RestockParamsValidator
          attr_reader :errors

          def initialize(params)
            @params = params
            @errors = []
          end

          def validate
            if @params[:variant_id].blank? && @params[:sku].blank?
              @errors << { status: 422, detail: "Parameters must include either 'variant_id' or 'sku'"}
            end

            if @params[:original_stock_location_id].blank?
              @errors << { status: 422, detail: "Parameters must include 'original_stock_location_id'"}
            end

            if @params[:user_id].blank?
              @errors << { status: 422, detail: "Parameters must include 'user_id'"}
            end

            @errors.empty?
          end
        end
      end
    end
  end
end
