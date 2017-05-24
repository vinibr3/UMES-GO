ActiveAdmin.register Extensao do
	menu label: "Extensões"
	belongs_to :entidade
	permit_params :lista_certificados_revogados, :cadeia_certificados_raiz
	actions :all, except: [:destroy, :show]

	filter :lista_certificados_revogados_file_name, label: "Lista Certificados Revogados"
	filter :cadeia_certificados_raiz_file_name, label: "Cadeia Certificados Raiz"

	index do
		column "Lista Certificados Revogados" do |extensao|
			a extensao.lista_certificados_revogados_file_name, href: extensao.lista_certificados_revogados.url
		end
		column "Cadeia Certificados Revogados" do |extensao|
			a extensao.cadeia_certificados_raiz_file_name, href: extensao.cadeia_certificados_raiz.url
		end
		actions
	end

	show do 
		panel "Arquivos" do
			attributes_table_for extensao do
				row "Lista Certificados Revogados" do
					a extensao.lista_certificados_revogados_file_name, href: extensao.lista_certificados_revogados.url
				end
				row "Cadeia Certificados Raiz" do
					a extensao.cadeia_certificados_raiz_file_name, href: extensao.cadeia_certificados_raiz.url
				end
			end
		end
	end

	form do |f|
		f.semantic_errors *f.object.errors.keys
		f.inputs "Arquivos" do
			f.input :lista_certificados_revogados, label: "Lista Certificados Revogados"
			f.input :cadeia_certificados_raiz, label: "Cadeia Certificados Raiz"
		end
		f.actions
	end

	controller do 
		before_filter { @page_title = "Extensões" }
	end

end