Spree.ready ($) ->
  Spree.onPayment = () ->
    if ($ '#checkout_form_payment').is('*')

      if ($ '#existing_cards').is('*')
        ($ '#payment-method-fields').hide()
        ($ '#payment-methods').hide()

        ($ '#use_existing_card_yes').click ->
          ($ '#payment-method-fields').hide()
          ($ '#payment-methods').hide()
          ($ '.existing-cc-radio').prop("disabled", false)

        ($ '#use_existing_card_no').click ->
          ($ '#payment-method-fields').show()
          ($ '#payment-methods').show()
          ($ '.existing-cc-radio').prop("disabled", true)


      $(".cardNumber").payment('formatCardNumber')
      $(".cardExpiry").payment('formatCardExpiry')
      $(".cardCode").payment('formatCardCVC')

      $(".cardNumber").change ->
        $(this).parent().siblings(".ccType").val($.payment.cardType(@value))

      ($ 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]').click(->
        ($ '#payment-methods li').hide()
        ($ '#payment_method_' + @value).show() if @checked
      )

      ($ '#cvv_link').on 'click', (event) ->
        windowName = 'cvv_info'
        windowOptions = 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1'
        window.open(($ this).attr('href'), windowName, windowOptions)
        event.preventDefault()

      # Activate already checked payment method if form is re-rendered
      # i.e. if user enters invalid data
      ($ 'input[type="radio"]:checked').click()

  Spree.onPayment()
