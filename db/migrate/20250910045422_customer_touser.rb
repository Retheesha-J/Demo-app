class CustomerTouser < ActiveRecord::Migration[8.0]
  def change
    rename_table :customers,:users
  end
end
