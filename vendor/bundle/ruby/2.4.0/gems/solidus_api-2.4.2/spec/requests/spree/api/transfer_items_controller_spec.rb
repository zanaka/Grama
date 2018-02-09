require 'spec_helper'

module Spree
  describe Api::TransferItemsController do

    let!(:stock_transfer) { create(:stock_transfer_with_items) }
    let(:transfer_item)   { stock_transfer.transfer_items.first }

    before do
      stub_authentication!
    end

    context "as a normal user" do
      describe "#create" do
        it "cannot create a transfer item" do
          post spree.api_stock_transfer_transfer_items_path(stock_transfer)
          expect(response.status).to eq 401
        end
      end

      describe "#update" do
        it "cannot update a transfer item" do
          put spree.api_stock_transfer_transfer_item_path(stock_transfer, transfer_item)
          expect(response.status).to eq 401
        end
      end

      describe "#destroy" do
        it "cannot delete a transfer item" do
          delete spree.api_stock_transfer_transfer_item_path(stock_transfer, transfer_item)
          expect(response.status).to eq 401
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      describe "#create" do
        subject do
          create_params = {
            transfer_item: {
              variant_id: variant_id,
              expected_quantity: 1
            }
          }
          post spree.api_stock_transfer_transfer_items_path(stock_transfer), params: create_params
        end

        context "valid parameters" do
          let(:variant)           { create(:variant) }
          let(:variant_id)        { variant.id }

          context "variant is available" do
            before do
              variant.stock_items.update_all(count_on_hand: 1)
            end

            it "can create a transfer item" do
              subject
              expect(response.status).to eq 201
            end

            it "creates a transfer item" do
              expect { subject }.to change { Spree::TransferItem.count }.by(1)
            end
          end

          context "variant is not available" do
            before do
              variant.stock_items.update_all(count_on_hand: 0)
            end

            it "returns an error status" do
              subject
              expect(response.status).to eq 422
            end

            it "does not create a transfer item" do
              expect { subject }.to_not change { Spree::TransferItem.count }
            end
          end
        end
      end

      describe "#update" do
        subject do
          update_params = { transfer_item: { received_quantity: received_quantity } }
          put spree.api_stock_transfer_transfer_item_path(stock_transfer, transfer_item), params: update_params
        end

        context "valid parameters" do
          let(:received_quantity) { 2 }

          it "can update a transfer item" do
            subject
            expect(response.status).to eq 200
          end

          it "updates the transfer item" do
            expect { subject }.to change { transfer_item.reload.received_quantity }.to(2)
          end
        end

        context "invalid parameters" do
          let(:received_quantity) { -5 }

          it "returns a 422" do
            subject
            expect(response.status).to eq 422
          end

          it "does not update the transfer item" do
            expect { subject }.to_not change { transfer_item.reload.received_quantity }
          end
        end
      end

      describe "#destroy" do
        subject { delete spree.api_stock_transfer_transfer_item_path(stock_transfer, transfer_item) }

        context "hasn't been finalized" do
          it "can delete a transfer item" do
            subject
            expect(response.status).to eq 200
          end

          it "deletes the transfer item" do
            expect { subject }.to change { Spree::TransferItem.count }.by(-1)
          end
        end

        context "has been finalized" do
          before do
            stock_transfer.update_attributes(finalized_at: Time.current)
          end

          it "returns an error status code" do
            subject
            expect(response.status).to eq 422
          end

          it "does not delete the transfer item" do
            expect { subject }.to_not change { Spree::TransferItem.count }
          end
        end
      end
    end
  end
end
