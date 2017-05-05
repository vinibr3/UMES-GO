module AdminUsersHelper
	def self.create_admin_user_default
		nome = "Super Admin"
		email = 'doti@doti.com.br'
		password = 'admindoti'
		usuario = "superadmin"
		AdminUser.create!(nome: nome, email: email, password: password, password_confirmation: password, 
            super_admin: "1", usuario: usuario) unless AdminUser.exists?(nome: nome, email: email, usuario: usuario)
	end 
end