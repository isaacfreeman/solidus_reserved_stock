module Spree
  module Api
    module V1
      # API Controller for reserving, restocking and expiring stock
      class ReservedStockItemsController < Spree::Api::BaseController
        before_action :authorize_reserving_stock

        rescue_from ActiveRecord::RecordNotFound, with: :not_found

        def index
          @reserved_stock_items = scope.all.page(params[:page]).per(params[:per_page])
          respond_with(@reserved_stock_items)
        end

        def reserve
          render_reserve_param_errors(params); return if performed?
          @reserved_stock_item = Spree::Stock::Reserver.new(variant, user, original_stock_location).reserve(
            params[:quantity],
            params[:expires_at]
          )
          if @reserved_stock_item.present?
            respond_with(@reserved_stock_item, status: :created, default_template: :show)
          else
            invalid_resource!(@reserved_stock_item)
          end
        end

        def restock
          render_restock_param_errors(params); return if performed?
          @reserved_stock_item = Spree::Stock::Reserver.new(variant, user, original_stock_location).restock(
            params[:quantity]
          )
          respond_with(@reserved_stock_item, status: :created, default_template: :show)
        end

        def restock_expired
          Spree::Stock::Reserver.new.restock_expired
          head 204 # return success with no body
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
          return Spree::Variant.where(sku: sku).first! if sku.present?
          Spree::Variant.find(variant_id)
        end

        def original_stock_location
          Spree::StockLocation.find(params[:original_stock_location_id])
        end

        def render_reserve_param_errors(params)
          validator = Validators::ReserveStockParamsValidator.new(params)
          render_errors(validator.errors) unless validator.validate
        end

        def render_restock_param_errors(params)
          validator = Validators::RestockParamsValidator.new(params)
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

        def not_found(error)
          @error = error
          render "spree/api/v1/reserved_stock_items/errors/entity_not_found", status: 404
        end
      end
    end
  end
end
