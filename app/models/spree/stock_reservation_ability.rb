module Spree
  class StockReservationAbility
    include CanCan::Ability

    def initialize(user)
      if user.has_spree_role?('admin')
        can :manage, Spree::ReservedStockItem
      end
    end
  end
end
