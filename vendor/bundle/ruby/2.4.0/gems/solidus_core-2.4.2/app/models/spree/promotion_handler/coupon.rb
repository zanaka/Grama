module Spree
  module PromotionHandler
    class Coupon
      attr_reader :order
      attr_accessor :error, :success, :status_code

      def initialize(order)
        @order = order
      end

      def apply
        if order.coupon_code.present?
          if promotion.present? && promotion.actions.exists?
            handle_present_promotion(promotion)
          elsif promotion_code && promotion_code.promotion.inactive?
            set_error_code :coupon_code_expired
          else
            set_error_code :coupon_code_not_found
          end
        end

        self
      end

      def set_success_code(c)
        @status_code = c
        @success = Spree.t(c)
      end

      def set_error_code(c)
        @status_code = c
        @error = Spree.t(c)
      end

      def promotion
        @promotion ||= begin
          if promotion_code && promotion_code.promotion.active?
            promotion_code.promotion
          end
        end
      end

      def successful?
        success.present? && error.blank?
      end

      private

      def promotion_code
        @promotion_code ||= Spree::PromotionCode.where(value: order.coupon_code.downcase).first
      end

      def handle_present_promotion(promotion)
        return promotion_usage_limit_exceeded if promotion.usage_limit_exceeded? || promotion_code.usage_limit_exceeded?
        return promotion_applied if promotion_exists_on_order?(order, promotion)
        unless promotion.eligible?(order, promotion_code: promotion_code)
          self.error = promotion.eligibility_errors.full_messages.first unless promotion.eligibility_errors.blank?
          return (error || ineligible_for_this_order)
        end

        # If any of the actions for the promotion return `true`,
        # then result here will also be `true`.
        result = promotion.activate(order: order, promotion_code: promotion_code)
        if result
          determine_promotion_application_result
        else
          set_error_code :coupon_code_unknown_error
        end
      end

      def promotion_usage_limit_exceeded
        set_error_code :coupon_code_max_usage
      end

      def ineligible_for_this_order
        set_error_code :coupon_code_not_eligible
      end

      def promotion_applied
        set_error_code :coupon_code_already_applied
      end

      def promotion_exists_on_order?(order, promotion)
        order.promotions.include? promotion
      end

      def determine_promotion_application_result
        detector = lambda { |p|
          p.source.promotion.codes.where(value: order.coupon_code.downcase).any?
        }

        # Check for applied adjustments.
        discount = order.line_item_adjustments.promotion.detect(&detector)
        discount ||= order.shipment_adjustments.promotion.detect(&detector)
        discount ||= order.adjustments.promotion.detect(&detector)

        if discount && discount.eligible
          order.recalculate
          set_success_code :coupon_code_applied
        elsif order.promotions.with_coupon_code(order.coupon_code)
          # if the promotion exists on an order, but wasn't found above,
          # we've already selected a better promotion
          set_error_code :coupon_code_better_exists
        else
          # if the promotion was created after the order
          set_error_code :coupon_code_not_found
        end
      end
    end
  end
end
