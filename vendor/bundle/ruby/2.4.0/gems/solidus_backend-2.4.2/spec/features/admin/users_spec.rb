require 'spec_helper'

describe 'Users', type: :feature do
  stub_authorization!
  let!(:country) { create(:country) }
  let!(:user_a) { create(:user_with_addresses, email: 'a@example.com') }
  let!(:user_b) { create(:user_with_addresses, email: 'b@example.com') }
  let!(:admin_role) { create(:role, name: 'admin') }
  let!(:user_role) { create(:role, name: 'user') }

  let(:order) { create(:completed_order_with_totals, user: user_a, number: "R123") }

  let(:order_2) do
    create(:completed_order_with_totals, user: user_a, number: "R456").tap do |o|
      li = o.line_items.last
      li.update_column(:price, li.price + 10)
    end
  end

  let(:orders) { [order, order_2] }

  shared_examples_for 'a user page' do
    it 'has lifetime stats' do
      orders
      visit current_url # need to refresh after creating the orders for specs that did not require orders
      within("#user-lifetime-stats") do
        [:total_sales, :num_orders, :average_order_value, :member_since].each do |stat_name|
          expect(page).to have_content Spree.t(stat_name)
        end
        expect(page).to have_content(order.total + order_2.total)
        expect(page).to have_content orders.count
        expect(page).to have_content(orders.sum(&:total) / orders.count)
        expect(page).to have_content I18n.l(user_a.created_at.to_date)
      end
    end

    it 'can go back to the users list' do
      expect(page).to have_link Spree::LegacyUser.model_name.human(count: :other), href: spree.admin_users_path
    end

    it 'can navigate to the account page' do
      expect(page).to have_link Spree.t(:"admin.user.account"), href: spree.edit_admin_user_path(user_a)
    end

    it 'can navigate to the order history' do
      expect(page).to have_link Spree.t(:"admin.user.order_history"), href: spree.orders_admin_user_path(user_a)
    end

    it 'can navigate to the items purchased' do
      expect(page).to have_link Spree.t(:"admin.user.items"), href: spree.items_admin_user_path(user_a)
    end
  end

  shared_examples_for 'a sortable attribute' do
    before { click_link sort_link }

    it "can sort asc" do
      within_table(table_id) do
        expect(page).to have_text text_match_1
        expect(page).to have_text text_match_2
        expect(text_match_1).to appear_before text_match_2
      end
    end

    it "can sort desc" do
      within_table(table_id) do
        # Ransack adds a ▲ to the sort link. With exact match Capybara is not able to find that link
        click_link sort_link, exact: false

        expect(page).to have_text text_match_1
        expect(page).to have_text text_match_2
        expect(text_match_2).to appear_before text_match_1
      end
    end
  end

  before do
    visit spree.admin_path
    click_link 'Users'
  end

  context 'users index' do
    context "email" do
      it_behaves_like "a sortable attribute" do
        let(:text_match_1) { user_a.email }
        let(:text_match_2) { user_b.email }
        let(:table_id) { "listing_users" }
        let(:sort_link) { "users_email_title" }
      end
    end

    it 'displays the correct results for a user search by email' do
      fill_in 'q_email_cont', with: user_a.email
      click_button 'Search'
      within_table('listing_users') do
        expect(page).to have_text user_a.email
        expect(page).not_to have_text user_b.email
      end
    end

    context "member since" do
      it_behaves_like "a sortable attribute" do
        let(:text_match_1) { user_a.email }
        let(:text_match_2) { user_b.email }
        let(:table_id) { "listing_users" }
        let(:sort_link) { Spree.t(:member_since) }
      end

      it 'displays the correct results for a user search by creation date' do
        user_a.update_column(:created_at, 2.weeks.ago)
        fill_in 'q_created_at_lt', with: 1.week.ago
        click_button 'Search'
        within_table('listing_users') do
          expect(page).to have_text user_a.email
          expect(page).not_to have_text user_b.email
        end
      end
    end

    context 'with users having roles' do
      before do
        user_a.spree_roles << admin_role
        user_b.spree_roles << user_role
      end

      it 'displays the correct results for a user search by role' do
        select 'admin', from: Spree.user_class.human_attribute_name(:spree_roles)
        click_button 'Search'
        within_table('listing_users') do
          expect(page).to have_text user_a.email
          expect(page).not_to have_text user_b.email
        end
      end
    end
  end

  context 'editing users' do
    before { click_link user_a.email }

    it_behaves_like 'a user page'

    it 'can edit the user email' do
      fill_in 'user_email', with: 'a@example.com99'
      click_button 'Update'

      expect(user_a.reload.email).to eq 'a@example.com99'
      expect(page).to have_text 'Account updated'
      expect(page).to have_field('user_email', with: 'a@example.com99')
    end

    it 'can edit the user password' do
      fill_in 'user_password', with: 'welcome'
      fill_in 'user_password_confirmation', with: 'welcome'
      click_button 'Update'

      expect(page).to have_text 'Account updated'
    end

    it 'can edit user roles' do
      click_link 'Account'

      check 'user_spree_role_admin'
      click_button 'Update'
      expect(page).to have_text 'Account updated'
      expect(find_field('user_spree_role_admin')).to be_checked
    end

    it 'can delete user roles' do
      user_a.spree_roles << Spree::Role.create(name: "dummy")
      click_link 'Account'

      user_a.spree_roles.each do |role|
        uncheck "user_spree_role_#{role.name}"
      end

      click_button 'Update'
      expect(page).to have_text 'Account updated'
      expect(find_field('user_spree_role_dummy')).not_to be_checked
      expect(user_a.reload.spree_roles).to be_empty
    end

    it 'can edit user shipping address' do
      click_link "Addresses"

      within("#admin_user_edit_addresses") do
        fill_in "user_ship_address_attributes_address1", with: "1313 Mockingbird Ln"
        click_button 'Update'
        expect(page).to have_field('user_ship_address_attributes_address1', with: "1313 Mockingbird Ln")
      end

      expect(user_a.reload.ship_address.address1).to eq "1313 Mockingbird Ln"
    end

    it 'can edit user billing address' do
      click_link "Addresses"

      within("#admin_user_edit_addresses") do
        fill_in "user_bill_address_attributes_address1", with: "1313 Mockingbird Ln"
        click_button 'Update'
        expect(page).to have_field('user_bill_address_attributes_address1', with: "1313 Mockingbird Ln")
      end

      expect(user_a.reload.bill_address.address1).to eq "1313 Mockingbird Ln"
    end

    context 'invalid entry' do
      around do |example|
        ::AlwaysInvalidUser = Class.new(Spree.user_class) do
          validate :always_invalid_email
          def always_invalid_email
            errors.add(:email, "is invalid")
          end
        end
        orig_class = Spree.user_class
        Spree.user_class = "AlwaysInvalidUser"

        example.run

        Spree.user_class = orig_class.name
        Object.send(:remove_const, "AlwaysInvalidUser")
      end

      it 'should show validation errors' do
        fill_in 'user_email', with: 'something'
        click_button 'Update'

        within('#errorExplanation') do
          expect(page).to have_content("Email is invalid")
        end

        within('.flash.error') do
          expect(page).to have_content("Email is invalid")
        end
      end
    end

    context 'no api key exists' do
      it 'can generate a new api key' do
        within("#admin_user_edit_api_key") do
          expect(user_a.spree_api_key).to be_blank
          click_button Spree.t('generate_key', scope: 'api')
        end

        expect(user_a.reload.spree_api_key).to be_present

        expect(page).to have_content('Key: (hidden)')
      end
    end

    context 'an api key exists' do
      before do
        user_a.generate_spree_api_key!
        expect(user_a.reload.spree_api_key).to be_present
        visit current_path
      end

      it 'can clear an api key' do
        expect(page).to have_css('#current-api-key')

        click_button Spree.t('clear_key', scope: 'api')

        expect(page).to have_no_css('#current-api-key')

        expect(user_a.reload.spree_api_key).to be_blank
      end

      it 'can regenerate an api key' do
        old_key = user_a.spree_api_key

        within("#admin_user_edit_api_key") do
          click_button Spree.t('regenerate_key', scope: 'api')
        end

        expect(user_a.reload.spree_api_key).to be_present
        expect(user_a.reload.spree_api_key).not_to eq old_key

        expect(page).to have_content('Key: (hidden)')
      end
    end
  end

  context 'order history with sorting' do
    before do
      orders
      click_link user_a.email
      within(".tabs") { click_link Spree.t(:"admin.user.order_history") }
    end

    it_behaves_like 'a user page'

    context "completed_at" do
      it_behaves_like "a sortable attribute" do
        let(:text_match_1) { I18n.l(order.completed_at.to_date) }
        let(:text_match_2) { I18n.l(order_2.completed_at.to_date) }
        let(:table_id) { "listing_orders" }
        let(:sort_link) { "orders_completed_at_title" }
      end
    end

    [:number, :total].each do |attr|
      context attr do
        it_behaves_like "a sortable attribute" do
          let(:text_match_1) { order.send(attr).to_s }
          let(:text_match_2) { order_2.send(attr).to_s }
          let(:table_id) { "listing_orders" }
          let(:sort_link) { "orders_#{attr}_title" }
        end
      end
    end

    context "state" do
      let(:text_match_1) { "Complete" }
      let(:text_match_2) { "Complete" }
      let(:table_id) { "listing_orders" }
      let(:sort_link) { "orders_#{attr}_title" }
    end
  end

  context 'items purchased with sorting' do
    before do
      orders
      click_link user_a.email
      within(".tabs") { click_link Spree.t(:"admin.user.items") }
    end

    it_behaves_like 'a user page'

    context "completed_at" do
      it_behaves_like "a sortable attribute" do
        let(:text_match_1) { I18n.l(order.completed_at.to_date) }
        let(:text_match_2) { I18n.l(order_2.completed_at.to_date) }
        let(:table_id) { "listing_items" }
        let(:sort_link) { "orders_completed_at_title" }
      end
    end

    context "number" do
      let(:text_match_1) { "R123" }
      let(:text_match_2) { "R456" }
      let(:table_id) { "listing_items" }
      let(:sort_link) { "orders_#{attr}_title" }
    end

    context "state" do
      let(:text_match_1) { "Complete" }
      let(:text_match_2) { "Complete" }
      let(:table_id) { "listing_items" }
      let(:sort_link) { "orders_#{attr}_title" }
    end

    it "has item attributes" do
      items = order.line_items | order_2.line_items
      expect(page).to have_table 'listing_items'
      within_table('listing_items') do
        items.each do |item|
          expect(page).to have_selector(".item-name", text: item.product.name)
          expect(page).to have_selector(".item-price", text: item.single_money.to_html)
          expect(page).to have_selector(".item-quantity", text: item.quantity)
          expect(page).to have_selector(".item-total", text: item.money.to_html)
        end
      end
    end
  end
end
