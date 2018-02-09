require 'spree/testing_support/factories/product_factory'
require 'spree/testing_support/factories/option_type_factory'

FactoryGirl.define do
  factory :product_option_type, class: 'Spree::ProductOptionType' do
    product
    option_type
  end
end
