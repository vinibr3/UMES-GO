class AddAttachmentVersoAlternativoToLayoutCarteirinhas < ActiveRecord::Migration
  def self.up
    change_table :layout_carteirinhas do |t|
      t.attachment :verso_alternativo
    end
  end

  def self.down
    remove_attachment :layout_carteirinhas, :verso_alternativo
  end
end