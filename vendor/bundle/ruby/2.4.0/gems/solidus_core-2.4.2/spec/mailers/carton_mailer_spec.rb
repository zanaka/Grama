require 'rails_helper'
require 'email_spec'

RSpec.describe Spree::CartonMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:carton) { create(:carton) }
  let(:order) { carton.orders.first }

  # Regression test for https://github.com/spree/spree/issues/2196
  it "doesn't include out of stock in the email body" do
    shipment_email = Spree::CartonMailer.shipped_email(order: order, carton: carton)
    expect(shipment_email).not_to have_body_text(%{Out of Stock})
    expect(shipment_email).to have_body_text(%{Your order has been shipped})
    expect(shipment_email.subject).to eq "#{order.store.name} Shipment Notification ##{order.number}"
  end

  context "with resend option" do
    subject do
      Spree::CartonMailer.shipped_email(order: order, carton: carton, resend: true).subject
    end
    it { is_expected.to match /^\[RESEND\] / }
  end

  context "emails must be translatable" do
    context "shipped_email" do
      context "pt-BR locale" do
        before do
          pt_br_shipped_email = { spree: { shipment_mailer: { shipped_email: { dear_customer: 'Caro Cliente,' } } } }
          I18n.backend.store_translations :'pt-BR', pt_br_shipped_email
          I18n.locale = :'pt-BR'
        end

        after do
          I18n.locale = I18n.default_locale
        end

        specify do
          shipped_email = Spree::CartonMailer.shipped_email(order: order, carton: carton)
          expect(shipped_email).to have_body_text("Caro Cliente,")
        end
      end
    end
  end
end
