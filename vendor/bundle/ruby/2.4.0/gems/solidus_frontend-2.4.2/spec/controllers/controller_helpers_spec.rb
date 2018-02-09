require 'spec_helper'

# In this file, we want to test that the controller helpers function correctly
# So we need to use one of the controllers inside Spree.
# ProductsController is good.
describe Spree::ProductsController, type: :controller do
  before do
    I18n.enforce_available_locales = false
    Spree::Frontend::Config[:locale] = :de
  end

  after do
    Spree::Frontend::Config[:locale] = :en
    I18n.locale = :en
    I18n.enforce_available_locales = true
  end

  # Regression test for https://github.com/spree/spree/issues/1184
  it "sets the default locale based off Spree::Frontend::Config[:locale]" do
    expect(I18n.locale).to eq(:en)
    get :index
    expect(I18n.locale).to eq(:de)
  end
end
