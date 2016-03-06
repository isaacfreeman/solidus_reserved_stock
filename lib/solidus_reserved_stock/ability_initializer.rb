class AbilityInitializer < Rails::Railtie
  initializer "solidus_reserved_stock.configure_rails_initialization" do
    Spree::Ability.register_ability(Spree::StockReservationAbility)
  end
end
