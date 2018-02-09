require 'spec_helper'

describe "New Order", type: :feature do
  include OrderFeatureHelper

  let!(:product) { create(:product_in_stock) }
  let!(:state) { create(:state, state_code: 'CA') }
  let!(:store) { create(:store) }
  let!(:user) { create(:user, ship_address: create(:address), bill_address: create(:address)) }
  let!(:payment_method) { create(:check_payment_method) }
  let!(:shipping_method) { create(:shipping_method, cost: 0.0) }

  stub_authorization!

  before do
    visit spree.admin_path
    click_on "Orders"
    click_on "New Order"
  end

  it "does check if you have a billing address before letting you add shipments" do
    click_on "Shipments"
    expect(page).to have_content 'Please fill in customer info'
    expect(current_path).to eql(spree.edit_admin_order_customer_path(Spree::Order.last))
  end

  it "completes new order succesfully without using the cart", js: true do
    add_line_item product.name

    click_on "Customer"

    within "#select-customer" do
      targetted_select2_search user.email, from: "#s2id_customer_search"
    end

    expect(page).to have_checked_field('order_use_billing')
    fill_in_address
    click_on "Update"

    click_on "Payments"
    click_on "Update"

    expect(current_path).to eql(spree.admin_order_payments_path(Spree::Order.last))

    click_on "Confirm"
    click_on "Complete Order"

    expect(current_path).to eql(spree.edit_admin_order_path(Spree::Order.last))

    click_on "Payments"
    click_icon "capture"

    click_on "Shipments"
    click_on "Ship"

    within '.carton-state' do
      expect(page).to have_content('Shipped')
    end
  end

  it 'can create split payments', js: true do
    add_line_item product.name

    click_on "Customer"

    within "#select-customer" do
      targetted_select2_search user.email, from: "#s2id_customer_search"
    end

    expect(page).to have_checked_field('order_use_billing')
    fill_in_address
    click_on "Update"

    click_on "Payments"
    fill_in "Amount", with: '10.00'
    click_on 'Update'

    click_on 'New Payment'
    fill_in "Amount", with: '29.98'
    click_on 'Update'

    expect(page).to have_content("$10.00")
    expect(page).to have_content("$29.98")
  end

  context "adding new item to the order", js: true do
    it "inventory items show up just fine and are also registered as shipments" do
      add_line_item product.name

      within(".line-items") do
        expect(page).to have_content(product.name)
      end

      click_on "Customer"

      within "#select-customer" do
        targetted_select2_search user.email, from: "#s2id_customer_search"
      end

      expect(page).to have_checked_field('order_use_billing')
      fill_in_address
      click_on "Update"

      click_on "Shipments"

      within(".stock-contents") do
        expect(page).to have_content(product.name)
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/3958
  context "without a delivery step", js: true do
    before do
      allow(Spree::Order).to receive_messages checkout_step_names: [:address, :payment, :confirm, :complete]
    end

    it "can still see line items" do
      add_line_item product.name

      within(".line-items") do
        within(".line-item-name") do
          expect(page).to have_content(product.name)
        end
        within(".line-item-qty-show") do
          expect(page).to have_content("1")
        end
        within(".line-item-price") do
          expect(page).to have_content(product.price)
        end
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/3336
  context "start by customer address" do
    it "completes order fine", js: true do
      click_on "Customer"

      within "#select-customer" do
        targetted_select2_search user.email, from: "#s2id_customer_search"
      end

      expect(page).to have_checked_field('order_use_billing')
      fill_in_address
      click_on "Update"

      # Automatically redirected to Shipments page
      select2_search product.name, from: Spree.t(:name_or_sku)

      click_icon :plus

      expect(page).to have_css('.stock-item')

      click_on "Payments"
      click_on "Continue"

      within(".additional-info") do
        expect(page).to have_content("Confirm")
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/5327
  context "customer with default credit card", js: true do
    let!(:credit_card) { create(:credit_card, user: user) }

    before do
      user.wallet.add(credit_card)
    end

    it "transitions to delivery not to complete" do
      add_line_item product.name

      expect(page).to have_css('.line-item')

      click_link "Customer"
      targetted_select2 user.email, from: "#s2id_customer_search"
      click_button "Update"
      expect(Spree::Order.last.state).to eq 'delivery'
    end
  end

  context "customer with attempted XSS", js: true do
    let(:xss_string) { %(<script>throw("XSS")</script>) }
    before do
      user.update!(email: xss_string)
    end
    it "displays the user's email escaped without executing" do
      click_on "Customer"
      targetted_select2_search user.email, from: "#s2id_customer_search"
      expect(page).to have_field("Customer E-Mail", with: xss_string)
    end
  end

  def fill_in_address
    fill_in "First Name",                with: "John 99"
    fill_in "Last Name",                 with: "Doe"
    fill_in "Street Address",            with: "100 first lane"
    fill_in "Street Address (cont'd)",   with: "#101"
    fill_in "City",                      with: "Bethesda"
    fill_in "Zip Code",                  with: "20170"
    select state.name, from: "State"
    fill_in "Phone",                     with: "123-456-7890"
  end
end
