class EventoSerializer < ActiveModel::Serializer
	attributes :type, :titulo, :data, :local, :texto, :folder_url, :url

	def type
		"aviso"
	end

	def data 
		self.object.data.strftime("%d/%m/%Y")
	end

	def folder_url
		self.object.folder.url
	end

	def url
		"http://162.243.72.115/eventos/#{self.object.id}"
	end
end