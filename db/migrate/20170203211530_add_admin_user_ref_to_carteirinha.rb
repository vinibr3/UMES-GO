class AddAdminUserRefToCarteirinha < ActiveRecord::Migration
  def change
    add_reference :carteirinhas, :admin_user, index: true, foreign_key: true
  end
end
