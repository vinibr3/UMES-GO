# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

EstadosHelper.populate
AdminUsersHelper.create_admin_user_default
EscolaridadesHelper.populate # deve ser populada antes de cursos devido a associação entre eles
CursosHelper.populate_todos_cursos
InstituicaoEnsinoHelper.populate_todas_instituicoes_ensino ["DF""MT","GO","MS"] # recebe um array com ufs das IEs a serem populados