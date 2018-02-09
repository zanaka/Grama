require 'spree/testing_support/factories/variant_factory'

FactoryGirl.define do
  factory :price, class: 'Spree::Price' do
    variant
    amount 19.99
    currency 'USD'
  end
end
