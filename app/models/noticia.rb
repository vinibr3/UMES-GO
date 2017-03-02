class Noticia < ActiveRecord::Base
	
	FILES_NAME_PERMIT = [/png\Z/, /jpe?g\Z/]
	FILES_CONTENT_TYPE = ['image/jpeg', 'image/png']
	LETRAS = /[A-Z a-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+/

	url_path = "/admin/:class/:id/:attachment/:style/:filename"

	has_attached_file :foto, :path => "#{url_path}"

	validates :titulo, length:{maximum: 150, too_long: "Máximo de 150 caracteres permitidos."}
	validates :autor, length:{maximum: 40, too_long: "Máximo de 50 caracteres permitidos."}, format:{with: LETRAS }
	validates_attachment_size :foto, :less_than => 2.megabytes
	validates_attachment_file_name :foto, :matches => FILES_NAME_PERMIT
	validates_attachment_content_type :foto, :content_type => FILES_CONTENT_TYPE

end