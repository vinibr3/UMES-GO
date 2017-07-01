class AddRefToAdminUser < ActiveRecord::Migration
  def change
    add_reference :admin_users, :entidade, index: true, foreign_key: true
  end
end
