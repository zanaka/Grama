require 'spec_helper'

describe "Promotion Adjustments", type: :feature, js: true do
  stub_authorization!

  context "creating a new promotion", js: true do
    before(:each) do
      visit spree.admin_path
      click_link "Promotions"
      click_link "New Promotion"
      expect(page).to have_title("New Promotion - Promotions")
    end

    it "should allow an admin to create a flat rate discount coupon promo" do
      fill_in "Name", with: "Promotion"
      fill_in "Promotion Code", with: "order"

      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      select "Item total", from: "Add rule of type"
      within('#rule_fields') { click_button "Add" }

      find('[id$=_preferred_amount]').set(30)
      within('#rule_fields') { click_button "Update" }

      select "Create whole-order adjustment", from: "Add action of type"
      within('#action_fields') { click_button "Add" }
      select "Flat Rate", from: "Base Calculator"
      within('#actions_container') { click_button "Update" }

      within('.calculator-fields') { fill_in "Amount", with: 5 }
      within('#actions_container') { click_button "Update" }

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.codes.first.value).to eq("order")

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::ItemTotal)
      expect(first_rule.preferred_amount).to eq(30)

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::FlatRate)
      expect(first_action_calculator.preferred_amount).to eq(5)
    end

    it "should allow an admin to create a single user coupon promo with flat rate discount" do
      fill_in "Name", with: "Promotion"
      fill_in "promotion[usage_limit]", with: "1"
      fill_in "Promotion Code", with: "single_use"

      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      select "Create whole-order adjustment", from: "Add action of type"
      within('#action_fields') { click_button "Add" }
      select "Flat Rate", from: "Base Calculator"
      within('#actions_container') { click_button "Update" }
      within('#action_fields') { fill_in "Amount", with: "5" }
      within('#actions_container') { click_button "Update" }

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.usage_limit).to eq(1)
      expect(promotion.codes.first.value).to eq("single_use")

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::FlatRate)
      expect(first_action_calculator.preferred_amount).to eq(5)
    end

    it "should allow an admin to create an automatic promo with flat percent discount" do
      fill_in "Name", with: "Promotion"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      select "Item total", from: "Add rule of type"
      within('#rule_fields') { click_button "Add" }

      find('[id$=_preferred_amount]').set(30)
      within('#rule_fields') { click_button "Update" }

      select "Create whole-order adjustment", from: "Add action of type"
      within('#action_fields') { click_button "Add" }
      select "Flat Percent", from: "Base Calculator"
      within('#actions_container') { click_button "Update" }
      within('.calculator-fields') { fill_in "Flat Percent", with: "10" }
      within('#actions_container') { click_button "Update" }

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.codes.first).to be_nil

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::ItemTotal)
      expect(first_rule.preferred_amount).to eq(30)

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::FlatPercentItemTotal)
      expect(first_action_calculator.preferred_flat_percent).to eq(10)
    end

    it "should allow an admin to create an product promo with percent per item discount" do
      create(:product, name: "RoR Mug")

      fill_in "Name", with: "Promotion"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      select "Product(s)", from: "Add rule of type"
      within("#rule_fields") { click_button "Add" }
      select2_search "RoR Mug", from: "Choose products"
      within('#rule_fields') { click_button "Update" }

      select "Create per-line-item adjustment", from: "Add action of type"
      within('#action_fields') { click_button "Add" }
      select "Percent Per Item", from: "Base Calculator"
      within('#actions_container') { click_button "Update" }
      within('.calculator-fields') { fill_in "Percent", with: "10" }
      within('#actions_container') { click_button "Update" }

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.codes.first).to be_nil

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::Product)
      expect(first_rule.products.map(&:name)).to include("RoR Mug")

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateItemAdjustments)
      first_action_calculator = first_action.calculator
      expect(first_action_calculator.class).to eq(Spree::Calculator::PercentOnLineItem)
      expect(first_action_calculator.preferred_percent).to eq(10)
    end

    it "should allow an admin to create an automatic promotion with free shipping (no code)" do
      fill_in "Name", with: "Promotion"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      select "Item total", from: "Add rule of type"
      within('#rule_fields') { click_button "Add" }
      find('[id$=_preferred_amount]').set(30)
      within('#rule_fields') { click_button "Update" }

      select "Free shipping", from: "Add action of type"
      within('#action_fields') { click_button "Add" }
      expect(page).to have_content('Makes all shipments for the order free')

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.codes).to be_empty
      expect(promotion.rules.first).to be_a(Spree::Promotion::Rules::ItemTotal)
      expect(promotion.actions.first).to be_a(Spree::Promotion::Actions::FreeShipping)
    end

    it "should allow an admin to create an automatic promotion" do
      fill_in "Name", with: "Promotion"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion).to be_apply_automatically
      expect(promotion.path).to be_nil
      expect(promotion.codes).to be_empty
      expect(promotion.rules).to be_blank
    end

    it "should allow an admin to create a promo requiring a landing page to be visited" do
      fill_in "Name", with: "Promotion"
      choose "URL Path"
      fill_in "Path", with: "content/cvv"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.path).to eq("content/cvv")
      expect(promotion).not_to be_apply_automatically
      expect(promotion.codes).to be_empty
      expect(promotion.rules).to be_blank
    end

    it "should allow an admin to create a promo with generated codes" do
      fill_in "Name", with: "Promotion"
      choose "Multiple promotion codes"
      fill_in "Base code", with: "testing"
      fill_in "Number of codes", with: "10"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      promotion = Spree::Promotion.find_by(name: "Promotion")
      expect(promotion.path).to be_nil
      expect(promotion).not_to be_apply_automatically
      expect(promotion.rules).to be_blank

      expect(promotion.codes.count).to eq(10)
    end

    it "ceasing to be eligible for a promotion with item total rule then becoming eligible again" do
      fill_in "Name", with: "Promotion"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("Promotion - Promotions")

      select "Item total", from: "Add rule of type"
      within('#rule_fields') { click_button "Add" }
      find('[id$=_preferred_amount]').set(50)
      within('#rule_fields') { click_button "Update" }

      select "Create whole-order adjustment", from: "Add action of type"
      within('#action_fields') { click_button "Add" }
      select "Flat Rate", from: "Base Calculator"
      within('#actions_container') { click_button "Update" }
      within('.calculator-fields') { fill_in "Amount", with: "5" }
      within('#actions_container') { click_button "Update" }

      promotion = Spree::Promotion.find_by(name: "Promotion")

      first_rule = promotion.rules.first
      expect(first_rule.class).to eq(Spree::Promotion::Rules::ItemTotal)
      expect(first_rule.preferred_amount).to eq(50)

      first_action = promotion.actions.first
      expect(first_action.class).to eq(Spree::Promotion::Actions::CreateAdjustment)
      expect(first_action.calculator.class).to eq(Spree::Calculator::FlatRate)
      expect(first_action.calculator.preferred_amount).to eq(5)
    end
  end
end
