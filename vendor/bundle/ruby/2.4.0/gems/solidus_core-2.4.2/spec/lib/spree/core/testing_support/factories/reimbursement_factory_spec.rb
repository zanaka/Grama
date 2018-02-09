require 'rails_helper'
require 'spree/testing_support/factories/reimbursement_factory'

RSpec.describe 'reimbursement factory' do
  let(:factory_class) { Spree::Reimbursement }

  describe 'plain reimbursement' do
    let(:factory) { :reimbursement }

    it_behaves_like 'a working factory'
  end

  describe 'total' do
    subject { FactoryGirl.create(:reimbursement).total }

    it { is_expected.to be_present }
  end
end
