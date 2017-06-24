class EscolaridadeSerializer < ActiveModel::Serializer
	attributes :id, :nome
	def id
		object.id.to_s if object.id
	end
end