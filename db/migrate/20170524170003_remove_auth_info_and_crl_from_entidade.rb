class RemoveAuthInfoAndCrlFromEntidade < ActiveRecord::Migration
  def change
  	remove_column :entidades, :auth_info_access
  	remove_column :entidades, :crl_dist_points
  end
end
