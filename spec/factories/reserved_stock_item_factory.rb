FactoryGirl.define do
  factory :reserved_stock_item, class: Spree::ReservedStockItem do
    backorderable true
    stock_location
    variant { FactoryGirl.create(:variant) }
    after(:create) { |object| object.adjust_count_on_hand(10) }
  end
end
