module Spree
  module Api
    module V1
      # API Controller for reserving, restocking and expiring stock
      class ReservedStockItemsController < Spree::Api::BaseController
        before_action :authorize_reserving_stock

        def index
          @reserved_stock_items = scope.all.page(params[:page]).per(params[:per_page])
          respond_with(@reserved_stock_items)
        end

        def reserve
          render_reserve_param_errors(params); return if performed?
          @reserved_stock_item = Spree::Stock::Reserver.new.reserve(
            variant,
            original_stock_location,
            user,
            params[:quantity],
            params[:expires_at]
          )
          respond_with(@reserved_stock_item, status: :created, default_template: :show)
        rescue => e
          # TODO: Appropriate error if @reserved_stock_item not returned
          invalid_resource!(@reserved_stock_item)
        end

        def restock
          @reserved_stock_item = Spree::Stock::Reserver.new.restock(
            variant, user, params[:quantity]
          )
          respond_with(@reserved_stock_item, status: :created, default_template: :show)
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

        def user
          Spree.user_class.find(params[:user_id])
        end

        def variant
          variant_id = params[:variant_id]
          sku = params[:sku]
          return Spree::Variant.find(variant_id) if variant_id.present?
          return Spree::Variant.find_by(sku: sku) if sku.present?
          nil
        end

        def original_stock_location
          Spree::StockLocation.find(params[:original_stock_location_id])
        end

        def render_reserve_param_errors(params)
          validator = Validators::ReserveStockParamsValidator.new(params)
          render_errors(validator.errors) unless validator.validate
        end

        def render_errors(errors)
          return if errors.blank?
          Rails.logger.error errors
          render json: {'errors': errors}.to_json, status: 422
        end

        def scope
          base_scope = if params[:user_id].present?
            user
          else
            Spree::StockLocation.reserved_items_location
          end
          base_scope.reserved_stock_items.accessible_by(current_ability, :read).includes(:variant)
        end
      end
    end
  end
end
