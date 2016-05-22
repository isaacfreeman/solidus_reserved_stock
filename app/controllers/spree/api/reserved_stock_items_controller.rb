module Spree
  module Api
    class ReservedStockItemsController < Spree::Api::BaseController
      before_action :authorize_reserving_stock

      # TODO: Find variant by SKU
      def reserve
        @reserved_stock_item = Spree::Stock::Reserver.new.reserve(
          params[:variant],
          params[:original_stock_location],
          params[:user],
          params[:quantity],
          params[:expires_at]
        )
        respond_with(@reserved_stock_item, status: 201, default_template: :show)
      rescue => e
        invalid_resource!(@reserved_stock_item)
      end

      def restock
        @reserved_stock_item = Spree::Stock::Reserver.new.restock(
          params[:variant],
          params[:user],
          params[:quantity]
        )
        respond_with(@reserved_stock_item, status: 201, default_template: :show)
      rescue => e
        invalid_resource!(@reserved_stock_item)
      end

      def restock_expired
        Spree::Stock::Reserver.new.restock_expired
        head 204 # return success with no body
      rescue => e
        # TODO: error message
      end

      private

      def authorize_reserving_stock
        authorize! :manage, ReservedStockItem
      end
    end
  end
end
