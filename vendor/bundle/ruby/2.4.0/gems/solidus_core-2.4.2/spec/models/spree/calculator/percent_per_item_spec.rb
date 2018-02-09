require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

module Spree
  class Calculator
    RSpec.describe PercentPerItem, type: :model do
      it_behaves_like 'a calculator with a description'
    end
  end
end
