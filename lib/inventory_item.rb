module SaasuConnect
	class InventoryItem < Base
		has_many :item_invoice_items
		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int
			self.fields[:last_updated_uid] = :string
			self.fields[:code] = :string
			self.fields[:description] = :string
			self.fields[:is_active] = :bool
			self.fields[:notes] = :string
			self.fields[:is_inventoried] = :bool
			self.fields[:asset_account_uid] = :int
			self.fields[:current_value] = :float
			self.fields[:is_bought] = :bool
			self.fields[:purchase_expense_account_uid] = :int
			self.fields[:purchase_tax_code] = :string
			self.fields[:minimum_stock_level] = :float
			self.fields[:primary_supplier_contact_uid] = :int
			self.fields[:primary_supplier_item_code] = :string
			self.fields[:default_re_order_quantity] = :float
			self.fields[:is_sold] = :bool
			self.fields[:sale_income_account_uid] = :int
			self.fields[:sale_tax_code] = :string
			self.fields[:sale_co_s_account_uid] = :int

			self.fields[:utc_first_created] = :date_time
			self.fields[:utc_last_modified] = :date_time

			self.fields[:stock_on_hand] = :int

			self.fields[:average_cost] = :float
			self.fields[:selling_price] = :float
			self.fields[:is_selling_price_inc_tax] = :bool
			self.fields[:buying_price] = :float
			self.fields[:is_buying_price_inc_tax] = :bool
			self.fields[:rrp_incl_tax] = :float

			self.fields[:quantity_on_order] = :float
			self.fields[:quantity_committed] = :float
			self.fields[:is_bought] = :bool

			super(data)
		end
	end
end
