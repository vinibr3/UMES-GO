class CidadeSerializer < ActiveModel::Serializer
	attributes :id, :nome, :estado_id

	def id
		object.id.to_s if object.id
	end

	def estado_id
		object.estado.id.to_s if object.estado
	end	
end