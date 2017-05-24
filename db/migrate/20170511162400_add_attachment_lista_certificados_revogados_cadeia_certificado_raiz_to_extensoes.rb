class AddAttachmentListaCertificadosRevogadosCadeiaCertificadoRaizToExtensoes < ActiveRecord::Migration
  def self.up
    change_table :extensoes do |t|
      t.attachment :lista_certificados_revogados
      t.attachment :cadeia_certificados_raiz
    end
  end

  def self.down
    remove_attachment :extensoes, :lista_certificados_revogados
    remove_attachment :extensoes, :cadeia_certificados_raiz
  end
end
