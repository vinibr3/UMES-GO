class Extensao < ActiveRecord::Base
  belongs_to :entidade
  url_path = "/admin/entidade/extensoes/:class/:id/:attachment/:style/:filename"

  has_attached_file :lista_certificados_revogados, path: url_path
  validates_attachment_size :lista_certificados_revogados, :less_than => 1.megabytes
  validates_attachment_file_name :lista_certificados_revogados, :matches => [/crl\Z/]
  validates_attachment_content_type :lista_certificados_revogados, 
  		:content_type=> ['application/pkix-crl', 'application/x-pkcs7-crl']

  has_attached_file :cadeia_certificados_raiz, path: url_path
  validates_attachment_size :cadeia_certificados_raiz, :less_than => 1.megabytes
  validates_attachment_file_name :cadeia_certificados_raiz, :matches => [/p7b\Z/]
  validates_attachment_content_type :cadeia_certificados_raiz, 
  		:content_type=> ['application/x-pkcs7-certificates', 'application/pkcs7-mime']

  validates_presence_of :lista_certificados_revogados, :cadeia_certificados_raiz

  def url_for_crl
  	"extensoes/crl/#{self.id}.crl" 
  end

  def url_for_aia
  	"extensoes/aia/#{self.id}.p7b"
  end

end
