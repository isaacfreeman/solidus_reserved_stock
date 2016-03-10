module Spree
  module Admin
    UsersController.class_eval do
      class_attribute :variant_display_attributes
      self.variant_display_attributes = [
        { translation_key: :sku, attr_name: :sku },
        { translation_key: :name, attr_name: :name }
      ]

      def reserved_stock_items
        @reserved_stock_items = @user.reserved_stock_items
        @variant_display_attributes = self.class.variant_display_attributes
      end
    end
  end
end
