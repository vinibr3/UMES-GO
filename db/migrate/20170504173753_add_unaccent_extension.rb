class AddUnaccentExtension < ActiveRecord::Migration
  def change
  	execute <<-SQL 
  		CREATE EXTENSION IF NOT EXISTS unaccent 
  	SQL
  end
end
