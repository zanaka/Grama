require 'spec_helper'

describe "Shipping Methods", type: :feature do
  stub_authorization!
  let!(:zone) { create(:global_zone) }
  let!(:shipping_method) { create(:shipping_method, zones: [zone]) }

  before do
    visit spree.admin_path
    click_link "Settings"
    click_link "Shipping"
  end

  context "show" do
    it "should display existing shipping methods" do
      within_row(1) do
        expect(column_text(1)).to eq(shipping_method.name)
        expect(column_text(2)).to eq(zone.name)
        expect(column_text(3)).to eq("Flat rate")
        expect(column_text(4)).to eq("Yes")
      end
    end
  end

  context "create", js: true do
    it "should be able to create a new shipping method" do
      click_link "New Shipping Method"

      fill_in "shipping_method_name", with: "bullock cart"

      within("#shipping_method_categories_field") do
        check first("input[type='checkbox']")["name"]
      end

      click_on "Create"
      expect(current_path).to eql(spree.edit_admin_shipping_method_path(Spree::ShippingMethod.last))
    end
  end

  # Regression test for https://github.com/spree/spree/issues/1331
  context "update" do
    it "can update the existing calculator", js: true do
      within("#listing_shipping_methods") do
        click_icon :edit
      end

      fill_in 'Amount', with: 20

      click_button "Update"

      expect(page).to have_content 'successfully updated'
      expect(page).to have_field 'Amount', with: '20.0'
    end

    it "can change the calculator", js: true do
      within("#listing_shipping_methods") do
        click_icon :edit
      end

      select 'Flexible Rate per package item', from: 'Base Calculator'

      fill_in 'First Item', with: 10
      fill_in 'Additional Item', with: 20

      click_button "Update"

      expect(page).to have_content 'successfully updated'
      expect(page).to have_field 'First Item', with: '10.0'
      expect(page).to have_field 'Additional Item', with: '20.0'
    end
  end
end
