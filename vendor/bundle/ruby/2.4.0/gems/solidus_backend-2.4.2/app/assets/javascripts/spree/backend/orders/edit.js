$(document).ready(function () {
  'use strict';

  $('[data-hook="add_product_name"]').find('.variant_autocomplete').variantAutocomplete({ in_stock_only: true });
  $("[data-hook='admin_orders_index_search']").find(".variant_autocomplete").variantAutocomplete();
});
