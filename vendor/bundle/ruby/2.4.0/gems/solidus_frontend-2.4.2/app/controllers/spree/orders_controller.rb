module Spree
  class OrdersController < Spree::StoreController
    before_action :check_authorization
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    helper 'spree/products', 'spree/orders'

    respond_to :html

    before_action :assign_order, only: :update
    # note: do not lock the #edit action because that's where we redirect when we fail to acquire a lock
    around_action :lock_order, only: :update
    before_action :apply_coupon_code, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

    def show
      @order = Spree::Order.find_by!(number: params[:id])
    end

    def update
      if @order.contents.update_cart(order_params)
        @order.next if params.key?(:checkout) && @order.cart?

        respond_with(@order) do |format|
          format.html do
            if params.key?(:checkout)
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to cart_path
            end
          end
        end
      else
        respond_with(@order)
      end
    end

    # Shows the current incomplete order from the session
    def edit
      @order = current_order || Spree::Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
      associate_user
    end

    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      @order   = current_order(create_order_if_necessary: true)
      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].present? ? params[:quantity].to_i : 1

      # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
      if !quantity.between?(1, 2_147_483_647)
        @order.errors.add(:base, Spree.t(:please_enter_reasonable_quantity))
      end

      begin
        @line_item = @order.contents.add(variant, quantity)
      rescue ActiveRecord::RecordInvalid => e
        @order.errors.add(:base, e.record.errors.full_messages.join(", "))
      end

      respond_with(@order) do |format|
        format.html do
          if @order.errors.any?
            flash[:error] = @order.errors.full_messages.join(", ")
            redirect_back_or_default(spree.root_path)
            return
          else
            redirect_to cart_path
          end
        end
      end
    end

    def populate_redirect
      flash[:error] = Spree.t(:populate_get_error)
      redirect_to('/cart')
    end

    def empty
      if @order = current_order
        @order.empty!
      end

      redirect_to spree.cart_path
    end

    def accurate_title
      if @order && @order.completed?
        Spree.t(:order_number, number: @order.number)
      else
        Spree.t(:shopping_cart)
      end
    end

    def check_authorization
      cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
      order = Spree::Order.find_by(number: params[:id]) || current_order

      if order
        authorize! :edit, order, cookies.signed[:guest_token]
      else
        authorize! :create, Spree::Order
      end
    end

    private

    def order_params
      if params[:order]
        params[:order].permit(*permitted_order_attributes)
      else
        {}
      end
    end

    def assign_order
      @order = current_order
      unless @order
        flash[:error] = Spree.t(:order_not_found)
        redirect_to(root_path) && return
      end
    end
  end
end
