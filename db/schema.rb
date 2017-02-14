# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170214012402) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "nome"
    t.string   "email",                            default: "",  null: false
    t.string   "usuario"
    t.string   "cpf"
    t.string   "rg"
    t.string   "expedidor_rg"
    t.string   "uf_expedidor_rg"
    t.date     "data_nascimento"
    t.string   "sexo"
    t.string   "celular"
    t.string   "telefone"
    t.string   "logradouro"
    t.string   "numero"
    t.string   "complemento"
    t.string   "setor"
    t.string   "cep"
    t.string   "super_admin",            limit: 1, default: "0", null: false
    t.string   "status",                 limit: 1, default: "1", null: false
    t.string   "encrypted_password",               default: "",  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cidade_id"
  end

  add_index "admin_users", ["cidade_id"], name: "index_admin_users_on_cidade_id", using: :btree
  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "assets", force: :cascade do |t|
    t.string   "storage_uid"
    t.string   "storage_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "storage_width"
    t.integer  "storage_height"
    t.float    "storage_aspect_ratio"
    t.integer  "storage_depth"
    t.string   "storage_format"
    t.string   "storage_mime_type"
    t.string   "storage_size"
  end

  create_table "avisos", force: :cascade do |t|
    t.text     "aviso"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "carteirinhas", force: :cascade do |t|
    t.string   "nome"
    t.string   "rg"
    t.string   "cpf"
    t.date     "data_nascimento"
    t.string   "matricula"
    t.string   "expedidor_rg"
    t.string   "uf_expedidor_rg"
    t.string   "instituicao_ensino"
    t.string   "cidade_inst_ensino"
    t.string   "escolaridade"
    t.string   "uf_inst_ensino"
    t.string   "curso_serie"
    t.string   "codigo_uso"
    t.date     "nao_antes"
    t.date     "nao_depois"
    t.string   "qr_code"
    t.string   "status_versao_impressa",                       null: false
    t.string   "foto_file_name"
    t.string   "foto_content_type"
    t.integer  "foto_file_size"
    t.datetime "foto_updated_at"
    t.text     "certificado"
    t.integer  "estudante_id"
    t.integer  "layout_carteirinha_id"
    t.string   "alterado_por"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "valor"
    t.string   "forma_pagamento"
    t.string   "status_pagamento"
    t.string   "transaction_id"
    t.string   "comprovante_matricula_file_name"
    t.string   "comprovante_matricula_content_type"
    t.integer  "comprovante_matricula_file_size"
    t.datetime "comprovante_matricula_updated_at"
    t.string   "xerox_rg_file_name"
    t.string   "xerox_rg_content_type"
    t.integer  "xerox_rg_file_size"
    t.datetime "xerox_rg_updated_at"
    t.string   "xerox_cpf_file_name"
    t.string   "xerox_cpf_content_type"
    t.integer  "xerox_cpf_file_size"
    t.datetime "xerox_cpf_updated_at"
    t.integer  "entidade_id"
    t.datetime "aprovada_em"
    t.integer  "admin_user_id"
    t.integer  "numero_serie",                       limit: 8
  end

  add_index "carteirinhas", ["admin_user_id"], name: "index_carteirinhas_on_admin_user_id", using: :btree
  add_index "carteirinhas", ["entidade_id"], name: "index_carteirinhas_on_entidade_id", using: :btree
  add_index "carteirinhas", ["estudante_id"], name: "index_carteirinhas_on_estudante_id", using: :btree
  add_index "carteirinhas", ["layout_carteirinha_id"], name: "index_carteirinhas_on_layout_carteirinha_id", using: :btree

  create_table "cidades", force: :cascade do |t|
    t.string   "nome"
    t.boolean  "capital"
    t.integer  "estado_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cidades", ["estado_id"], name: "index_cidades_on_estado_id", using: :btree

  create_table "cursos", force: :cascade do |t|
    t.string   "nome"
    t.integer  "escolaridade_id"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "instituicao_ensino_id"
    t.string   "status",                limit: 1, default: "1"
  end

  add_index "cursos", ["escolaridade_id"], name: "index_cursos_on_escolaridade_id", using: :btree
  add_index "cursos", ["instituicao_ensino_id"], name: "index_cursos_on_instituicao_ensino_id", using: :btree

  create_table "entidades", force: :cascade do |t|
    t.string   "nome"
    t.string   "sigla"
    t.string   "email"
    t.string   "cnpj"
    t.string   "valor_carteirinha"
    t.string   "frete_carteirinha"
    t.string   "telefone"
    t.string   "logradouro"
    t.string   "numero"
    t.string   "complemento"
    t.string   "setor"
    t.string   "cep"
    t.string   "cidade"
    t.string   "uf"
    t.string   "nome_presidente"
    t.string   "email_presidente"
    t.string   "cpf_presidente"
    t.string   "rg_presidente"
    t.string   "expedidor_rg_presidente"
    t.string   "uf_expedidor_rg_presidente"
    t.date     "data_nascimento_presidente"
    t.string   "sexo_presidente"
    t.string   "celular_presidente"
    t.string   "telefone_presidente"
    t.string   "logradouro_presidente"
    t.string   "numero_presidente"
    t.string   "complemento_presidente"
    t.string   "cep_presidente"
    t.string   "cidade_presidente"
    t.string   "uf_presidente"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "usuario"
    t.string   "url_qr_code"
    t.string   "token_certificado"
    t.string   "dominio"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "auth_info_access"
    t.string   "crl_dist_points"
  end

  create_table "escolaridades", force: :cascade do |t|
    t.string   "nome"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "status",     limit: 1
  end

  create_table "estados", force: :cascade do |t|
    t.string   "nome"
    t.string   "sigla"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "estudantes", force: :cascade do |t|
    t.string   "nome"
    t.string   "email",                              default: "", null: false
    t.string   "cpf"
    t.string   "rg"
    t.string   "expedidor_rg"
    t.string   "uf_expedidor_rg"
    t.date     "data_nascimento"
    t.string   "sexo"
    t.string   "celular"
    t.string   "telefone"
    t.string   "logradouro"
    t.string   "numero"
    t.string   "complemento"
    t.string   "setor"
    t.string   "cep"
    t.string   "uf"
    t.integer  "instituicao_ensino_id"
    t.integer  "curso_id"
    t.string   "matricula"
    t.string   "foto_file_name"
    t.string   "foto_content_type"
    t.integer  "foto_file_size"
    t.datetime "foto_updated_at"
    t.string   "comprovante_matricula_file_name"
    t.string   "comprovante_matricula_content_type"
    t.integer  "comprovante_matricula_file_size"
    t.datetime "comprovante_matricula_updated_at"
    t.string   "xerox_rg_file_name"
    t.string   "xerox_rg_content_type"
    t.integer  "xerox_rg_file_size"
    t.datetime "xerox_rg_updated_at"
    t.string   "chave_acesso"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "xerox_cpf_file_name"
    t.string   "xerox_cpf_content_type"
    t.integer  "xerox_cpf_file_size"
    t.datetime "xerox_cpf_updated_at"
    t.integer  "entidade_id"
    t.integer  "cidade_id"
    t.integer  "admin_user_id"
  end

  add_index "estudantes", ["admin_user_id"], name: "index_estudantes_on_admin_user_id", using: :btree
  add_index "estudantes", ["cidade_id"], name: "index_estudantes_on_cidade_id", using: :btree
  add_index "estudantes", ["confirmation_token"], name: "index_estudantes_on_confirmation_token", unique: true, using: :btree
  add_index "estudantes", ["email"], name: "index_estudantes_on_email", unique: true, using: :btree
  add_index "estudantes", ["entidade_id"], name: "index_estudantes_on_entidade_id", using: :btree
  add_index "estudantes", ["reset_password_token"], name: "index_estudantes_on_reset_password_token", unique: true, using: :btree

  create_table "eventos", force: :cascade do |t|
    t.string   "titulo"
    t.datetime "data"
    t.string   "folder_file_name"
    t.string   "folder_content_type"
    t.integer  "folder_file_size"
    t.datetime "folder_updated_at"
    t.string   "local"
    t.text     "texto"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "instituicao_ensinos", force: :cascade do |t|
    t.string   "nome"
    t.string   "sigla"
    t.string   "cnpj"
    t.string   "logradouro"
    t.string   "numero"
    t.string   "cep"
    t.string   "complemento"
    t.integer  "cidade_id"
    t.integer  "estado_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "instituicao_ensinos", ["cidade_id"], name: "index_instituicao_ensinos_on_cidade_id", using: :btree
  add_index "instituicao_ensinos", ["estado_id"], name: "index_instituicao_ensinos_on_estado_id", using: :btree

  create_table "layout_carteirinhas", force: :cascade do |t|
    t.string   "anverso_file_name"
    t.string   "anverso_content_type"
    t.integer  "anverso_file_size"
    t.datetime "anverso_updated_at"
    t.string   "verso_file_name"
    t.string   "verso_content_type"
    t.integer  "verso_file_size"
    t.datetime "verso_updated_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "nome_posx"
    t.integer  "nome_posy"
    t.integer  "instituicao_ensino_posx"
    t.integer  "instituicao_ensino_posy"
    t.integer  "escolaridade_posx"
    t.integer  "escolaridade_posy"
    t.integer  "curso_posx"
    t.integer  "curso_posy"
    t.integer  "data_nascimento_posx"
    t.integer  "data_nascimento_posy"
    t.integer  "rg_posx"
    t.integer  "rg_posy"
    t.integer  "cpf_posx"
    t.integer  "cpf_posy"
    t.integer  "codigo_uso_posx"
    t.integer  "codigo_uso_posy"
    t.integer  "nao_depois_posx"
    t.integer  "nao_depois_posy"
    t.integer  "qr_code_posx"
    t.integer  "qr_code_posy"
    t.integer  "qr_code_width"
    t.integer  "qr_code_height"
    t.integer  "foto_posx"
    t.integer  "foto_posy"
    t.integer  "foto_width"
    t.integer  "foto_height"
    t.integer  "entidade_id"
    t.integer  "matricula_posx"
    t.integer  "matricula_posy"
    t.integer  "tamanho_fonte"
  end

  add_index "layout_carteirinhas", ["entidade_id"], name: "index_layout_carteirinhas_on_entidade_id", using: :btree

  create_table "noticias", force: :cascade do |t|
    t.string   "foto_file_name"
    t.string   "foto_content_type"
    t.integer  "foto_file_size"
    t.datetime "foto_updated_at"
    t.string   "titulo"
    t.string   "autor"
    t.text     "body"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "teste", id: false, force: :cascade do |t|
    t.string "nome"
    t.string "numero_serie"
  end

  add_foreign_key "admin_users", "cidades"
  add_foreign_key "carteirinhas", "admin_users"
  add_foreign_key "carteirinhas", "entidades"
  add_foreign_key "cidades", "estados"
  add_foreign_key "cursos", "escolaridades"
  add_foreign_key "cursos", "instituicao_ensinos"
  add_foreign_key "estudantes", "admin_users"
  add_foreign_key "estudantes", "cidades"
  add_foreign_key "estudantes", "entidades"
  add_foreign_key "instituicao_ensinos", "cidades"
  add_foreign_key "instituicao_ensinos", "estados"
  add_foreign_key "layout_carteirinhas", "entidades"
end
