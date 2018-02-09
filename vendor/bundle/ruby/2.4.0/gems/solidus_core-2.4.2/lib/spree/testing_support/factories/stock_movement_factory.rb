require 'spree/testing_support/factories/stock_item_factory'

FactoryGirl.define do
  factory :stock_movement, class: 'Spree::StockMovement' do
    quantity 1
    action 'sold'
    stock_item
  end

  trait :received do
    action 'received'
  end
end
