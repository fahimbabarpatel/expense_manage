class CreateBillPayers < ActiveRecord::Migration
  def change
    create_table :bill_payers do |t|
      t.integer :user_id
      t.integer :bill_id
      t.float :amount

      t.timestamps null: false
    end
  end
end
