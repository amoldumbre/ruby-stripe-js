class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.integer :amount
      t.string :description

      t.timestamps
    end
  end
end
