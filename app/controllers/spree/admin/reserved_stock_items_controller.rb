module Spree
  module Admin
    class ReservedStockItemsController < ResourceController
      before_action :load_user, only: [:index, :create, :new, :restock]
      before_action :load_variants, only: [:create, :new]
      before_action :load_original_stock_locations, only: [:create, :new]

      class_attribute :variant_display_attributes
      self.variant_display_attributes = [
        { translation_key: :sku, attr_name: :sku },
        { translation_key: :name, attr_name: :name }
      ]

      def index
        @reserved_stock_items = @user.reserved_stock_items
        @variant_display_attributes = self.class.variant_display_attributes
      end

      def create
        validator = Spree::Api::V1::Validators::ReserveStockParamsValidator.new(permitted_resource_params)

        if validator.validate
          variant = Spree::Variant.find(permitted_resource_params[:variant_id])
          original_stock_location = Spree::StockLocation.find(permitted_resource_params[:original_stock_location_id])
          @reserved_stock_item = Spree::Stock::Reserver.new(variant, @user, original_stock_location).reserve(
            variant,
            original_stock_location,
            @user,
            permitted_resource_params[:quantity].to_i,
            Time.zone.parse(permitted_resource_params[:expires_at])
          )
          flash[:success] = flash_message_for(@reserved_stock_item, :successfully_created)
          redirect_to admin_user_reserved_stock_items_path(@user)
        else
          flash[:error] = "#{Spree.t("admin.reserved_stock_item.unable_to_create")}: #{validator.errors}"
          render :new
        end
      rescue => e
        flash[:error] = "#{Spree.t("admin.reserved_stock_item.unable_to_create")}: #{e.message}"
        render :new
      end

      def restock
        variant = Spree::ReservedStockItem.find(params[:id]).variant
        Spree::Stock::Reserver.new(variant, @user, original_stock_location).restock(variant, @user)
        flash[:success] = flash_message_for(@reserved_stock_item, :successfully_restocked)
        redirect_to admin_user_reserved_stock_items_path(@user)
      rescue => e
        flash[:error] = "#{Spree.t("admin.reserved_stock_item.unable_to_restock")}: #{e.message}"
        redirect_to admin_user_reserved_stock_items_path(@user)
      end

      private

      def location_after_destroy
        :back
      end

      def location_after_save
        :back
      end

      def collection
        []
      end

      def permitted_resource_params
        params.require(:reserved_stock_item).permit!.
          merge(user_id: @user.id)
      end


      def load_user
        @user = Spree.user_class.find(params[:user_id])
      end

      def load_original_stock_locations
        @original_stock_locations = Spree::StockLocation.not_reserved_items.order_default
      end

      def load_variants
        @variants = Spree::Variant
                    .includes(option_values: :option_type)
                    .order(id: :desc)
      end
    end
  end
end
