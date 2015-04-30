class CreateCashBalances < ActiveRecord::Migration
  def change
    create_table :cash_balances do |t|
      t.integer :to
      t.integer :from
      t.float :amount
      t.integer :bill_id
      t.string :type

      t.timestamps null: false
    end
  end
end
