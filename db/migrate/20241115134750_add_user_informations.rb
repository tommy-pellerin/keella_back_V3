class AddUserInformations < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :birthday, :datetime
    add_column :users, :phone, :string
    add_reference :users, :city, index: true, foreign_key: true
    add_column :users, :id_verified, :boolean, default: false
    add_column :users, :professional, :boolean, default: false
    add_column :users, :is_admin, :boolean, default: false
    add_column :users, :status, :integer, default: 0
  end
end
