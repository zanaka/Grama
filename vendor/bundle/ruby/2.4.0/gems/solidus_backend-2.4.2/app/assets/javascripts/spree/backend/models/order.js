//= require spree/backend/routes
//= require spree/backend/collections/line_items
//= require spree/backend/models/address

Spree.Models.Order = Backbone.Model.extend({
  urlRoot: Spree.routes.orders_api,
  idAttribute: "number",

  relations: {
    "line_items": Spree.Collections.LineItems,
    "shipments": Backbone.Collection,
    "bill_address": Spree.Models.Address,
    "ship_address": Spree.Models.Address
  },

  advance: function(opts) {
    var options = {
      url: Spree.routes.checkouts_api + "/" + this.id + "/advance",
      type: 'PUT',
    };
    _.extend(options, opts);
    return this.fetch(options)
  }
});

Spree.Models.Order.fetch = function(number, opts) {
  var options = (opts || {});
  var model = new Spree.Models.Order({
    number: number,
    line_items: [],
    shipments: [],
    bill_address: {},
    ship_address: {},
  });
  model.fetch(options);
  return model;
}
