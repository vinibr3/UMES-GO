	ActiveAdmin.register LayoutCarteirinha do
		menu if: proc{current_admin_user.super_admin?}, priority: 4, parent: "Configurações"
		actions :all, except: [:destroy]

		permit_params :anverso, :verso, :nome_posx, :nome_posy, :instituicao_ensino_posx, :instituicao_ensino_posy,
		              :escolaridade_posx, :escolaridade_posy, :curso_posx, :curso_posy,
		              :data_nascimento_posx, :data_nascimento_posy, :rg_posx, :rg_posy,
		              :cpf_posx, :cpf_posy, :codigo_uso_posx, :codigo_uso_posy, 
		              :nao_depois_posx, :nao_depois_posy, :qr_code_posx, :qr_code_posy,
		              :qr_code_width, :qr_code_height, :foto_posx, :foto_posy,
		              :foto_width, :foto_height, :entidade_id, :matricula_posx, :matricula_posy, 
		              :tamanho_fonte, :font_color, :font_weight, :font_style, :font_name, :font_family, :font_box,
		              :verso_alternativo, :impressao_transparente

		filter :anverso_file_name
		filter :verso_file_name

		index do
			selectable_column
	    	id_column
	    	column :anverso_file_name
	    	column :verso_file_name
	    	column "Entidade" do |layout|
	    		layout.entidade_nome 
	    	end
	    	actions
		end

		show do
			panel "Arquivos" do 
				attributes_table_for layout_carteirinha do
					row :anverso do 
						a layout_carteirinha.anverso_file_name, class: "show-popup-link", href: layout_carteirinha.anverso.url
					end
					row "Largura Anverso" do 
						layout_carteirinha.anverso_width			
					end
					row "Altura Anverso" do 
						layout_carteirinha.anverso_height			
					end
					row "Resolução X Anverso" do 
						layout_carteirinha.anverso_resolution_x			
					end
					row "Resolução Y Anverso" do 
						layout_carteirinha.anverso_resolution_y			
					end
					row :verso do 
						a layout_carteirinha.verso_file_name, class: "show-popup-link", href: layout_carteirinha.verso.url
					end
					row "Verso Alternativo" do
						a layout_carteirinha.verso_alternativo_file_name, class: "show-popup-link", href: layout_carteirinha.verso_alternativo.url
					end
					row :entidade do
						layout_carteirinha.entidade_nome
					end
				end
			end
			panel "Impressão" do
				attributes_table_for layout_carteirinha do
					row "Fundo Transparente" do
						layout_carteirinha.impressao_transparente
					end
				end
			end
			panel "Fonte" do 
				attributes_table_for layout_carteirinha do
					row "Nome" do
						layout_carteirinha.font_name
					end
					row "Família" do
						layout_carteirinha.font_family
					end
					row "Tamanho" do
						layout_carteirinha.tamanho_fonte
					end
					row "Cor" do
						layout_carteirinha.font_color
					end
					row "Peso" do
						Magick::Draw::FONT_WEIGHT_NAMES[layout_carteirinha.font_weight.to_i]
					end
					row "Estilo" do
						Magick::Draw::STYLE_TYPE_NAMES[layout_carteirinha.font_style.to_i]
					end
					row "Caixa" do
						layout_carteirinha.font_box
					end
				end
			end
			panel "Posições de Informações" do
				columns do
					column do
						attributes_table_for layout_carteirinha do
							row :nome_posx
							row :instituicao_ensino_posx
							row :escolaridade_posx
							row :curso_posx
							row :data_nascimento_posx
							row :rg_posx
							row :cpf_posx
							row :matricula_posx
							row :codigo_uso_posx
							row "VALIDADE POSX" do 
								layout_carteirinha.nao_depois_posx
							end
							row :qr_code_posx 
							row :qr_code_width
							row :foto_posx
							row :foto_width
						end
					end
					column do
						attributes_table_for layout_carteirinha do
							row :nome_posy
							row :instituicao_ensino_posy
							row :escolaridade_posy
							row :curso_posy
							row :data_nascimento_posy
							row :rg_posy
							row :cpf_posy
							row :matricula_posy
							row :codigo_uso_posy
							row "VALIDADE POSY" do
							 layout_carteirinha.nao_depois_posy
							end
							row :qr_code_posy
							row :qr_code_height
							row :foto_posy
							row :foto_height
						end
					end
				end
			end
			render inline: "<script type='text/javascript'>$('.show-popup-link').magnificPopup({type: 'image'});</script>"
		end

		form :html => { :enctype => "multipart/form-data"}  do |f| 
			f.semantic_errors *f.object.errors.keys
			f.inputs "Layout", multipart: true do 
				f.input :anverso, label: "Frente", :hint => "Imagem Atual: #{f.object.anverso_file_name}"
				f.input :verso, label: "Verso", :hint => "Imagem Atual: #{f.object.verso_file_name}"
				f.input :verso_alternativo, label: "Verso Alternativo", :hint => "Imagem Atual: #{f.object.verso_alternativo_file_name}"
				f.input :entidade, collection: Entidade.order(:nome).map{|e| [e.nome, e.id]}, prompt: "Selecione Entidade", include_blank: false
			end
			f.inputs "Impressão" do
				f.input :impressao_transparente, as: :radio, label: "Fundo Transparente"
			end
			div class: 'inputs drag-and-drop' do
					div class: 'drag-pick' do
						ul class: 'list-fonte' do 
							f.input :font_name, label: "Fonte", collection: ['Arial', 'Helvetica', 'Times'], include_blank: false
							f.input :font_family, label: "Família", collection: ['serif', 'sans-serif', 'cursive'], include_blank: false
							f.input :tamanho_fonte, label: "Tamanho", collection: (11..50).flat_map{|i| [i]}, as: :select, include_blank: false
							f.input :font_color, label: "Cor"
							f.input :font_weight, label: "Peso", as: :select, include_blank: false, collection: Magick::Draw::FONT_WEIGHT_NAMES.map{|k,v| [v,k] }
							f.input :font_style, label: "Estilo", as: :select, include_blank: false, collection: Magick::Draw::STYLE_TYPE_NAMES.map{|k,v| [v,k] }
							f.input :font_box, label: "Case", as: :select, include_blank: false
						end
						hr
						ul class: 'list-pick' do
							li class: 'item-draggable item-required', id:'foto' do
								div do
									image_tag "foto.svg", class: 'foto'
								end
								span class: "mark mark-over" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'nome' do
								span "Nome"
								span class: "mark" do
									"*"
								end
							end
							 
							li class: 'item-draggable item-required', id:'instituicao-ensino' do
								span "Instituição de Ensino"
								span class: "mark" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'curso' do
								span "Curso"
								span class: "mark" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'data-nascimento' do
								span "Data Nascimento"
								span class: "mark" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'rg' do
								span "RG"
								span class: "mark" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'matricula' do
								span "Matrícula"
								span class: "mark" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'codigo-uso' do
								span "Código de Uso"
								span class: "mark" do
									"*"
								end
							end
							
							li class: 'item-draggable item-required', id:'qr-code' do
								div do
									image_tag "qr-code.svg", class: 'qr-code'
								end
								span class: "mark mark-over" do
									"*"
								end
							end
						end
						hr
						ul class: 'list-pick-facultativa' do 
							li class: 'item-draggable item-facultativo', id:'cpf' do
								span "CPF"
							end
							
							li class: 'item-draggable item-facultativo', id:'nao-depois' do
								span "Validade"
							end
							
							li class: 'item-draggable item-facultativo', id:'escolaridade' do
								span "Escolaridade"
							end
						end
					end
					div class: 'drag-fundo' do
						div class: 'form-inputs' do
							div id: 'nome_inputs' do
								f.input :nome_posx, as: :hidden, :input_html=>{id: "nome_posx"}
								f.input :nome_posy, as: :hidden, :input_html=>{id: "nome_posy"}
							end
							div id: 'instituicao-ensino_inputs' do
								f.input :instituicao_ensino_posx, as: :hidden, :input_html=>{id: "instituicao-ensino_posx"}
								f.input :instituicao_ensino_posy, as: :hidden, :input_html=>{id: "instituicao-ensino_posy"}
							end
							div id: 'curso_inputs' do 
								f.input :curso_posx, as: :hidden, :input_html=>{id: "curso_posx"}
								f.input :curso_posy, as: :hidden, :input_html=>{id: "curso_posy"}
							end
							div id: 'data-nascimento_inputs' do
								f.input :data_nascimento_posx, as: :hidden, :input_html=>{id: "data-nascimento_posx"}
								f.input :data_nascimento_posy, as: :hidden, :input_html=>{id: "data-nascimento_posy"}
							end
							div id: 'rg_inputs' do
								f.input :rg_posx, as: :hidden, :input_html=>{id: "rg_posx"}
								f.input :rg_posy, as: :hidden, :input_html=>{id: "rg_posy"}
							end
							div id: 'matricula_inputs' do
								f.input :matricula_posx, as: :hidden, :input_html=>{id: "matricula_posx"}
								f.input :matricula_posy, as: :hidden, :input_html=>{id: "matricula_posy"}
							end
							div id: 'codigo-uso_inputs' do
								f.input :codigo_uso_posx, as: :hidden, :input_html=>{id: "codigo-uso_posx"}
								f.input :codigo_uso_posy, as: :hidden, :input_html=>{id: "codigo-uso_posy"}
							end
							div id: 'qr-code_inputs' do
								f.input :qr_code_posx, as: :hidden, :input_html=>{id: "qr-code_posx"}
								f.input :qr_code_posy, as: :hidden, :input_html=>{id: "qr-code_posy"}
								f.input :qr_code_width, as: :hidden, :input_html=>{id: "qr-code_width"}
								f.input :qr_code_height, as: :hidden, :input_html=>{id: "qr-code_height"}
							end
							div id: 'foto_inputs' do
								f.input :foto_posx, as: :hidden, :input_html=>{id: "foto_posx"}
								f.input :foto_posy, as: :hidden, :input_html=>{id: "foto_posy"}
								f.input :foto_width, as: :hidden, :input_html=>{id: "foto_width"}
								f.input :foto_height, as: :hidden, :input_html=>{id: "foto_height"}
							end

							# itens nao obrigatórios
							div id: 'nao-depois_inputs' do
								f.input :nao_depois_posx, as: :hidden, :input_html=>{id: "nao-depois_posx"}
								f.input :nao_depois_posy, as: :hidden, :input_html=>{id: "nao-depois_posy"}
							end
							div id: 'cpf_inputs' do
								f.input :cpf_posx, as: :hidden, :input_html=>{id: "cpf_posx"}
								f.input :cpf_posy, as: :hidden, :input_html=>{id: "cpf_posy"}
							end
							div id: 'escolaridade_inputs' do
								f.input :escolaridade_posx, as: :hidden, :input_html=>{id: "escolaridade_posx"}
								f.input :escolaridade_posy, as: :hidden, :input_html=>{id: "escolaridade_posy"}
							end
						end
						ul class: 'list-layout' do # recebe elementos posicionados
							
						end
						div class: 'drag-layout' do # foto de background (layout)
							image_tag f.object.anverso.url, id: 'layout'
						end
					end
			end
			
			
			f.actions

			render inline: "<script type='text/javascript'>
							$( window ).load(function() {
	  
								
								setLayoutDraggables();
								setAttributosFont();
								setLayoutDraggables();
								checkAnversoErrors();
								resizeListLayout();

								var posicoes_required = null;
								var posicoes_facultativa = null;
								initListPick();

								function initListPick(){
									posicoes_required = new Object();
									$('.list-pick li').each(function(index, element){
										var target = $('#'+element.id);
										posicoes_required[element.id] = target.position();
									});
									posicoes_facultativa = new Object();
									$('.list-pick-facultativa li').each(function(index, element){
										var target = $('#'+element.id);
										posicoes_facultativa[element.id] = target.position();
									});
									console.log(posicoes_facultativa);
								}
								
								function resetFormInput(id){
									$(id+'_posx').val('');
									$(id+'_posy').val('');
								}

								// reseta inputs se há erros no input file 'anverso'
								function checkAnversoErrors(){
									if($('#layout_carteirinha_anverso_input p.inline-errors').length > 0){
										$('.form-inputs input').val('');
									}
								}

								$('.list-pick').droppable({
									accept: '.item-draggable'
								});

								$('.list-pick-facultativa').droppable({
									accept: '.item-facultativo',
									drop: function(event, ui){
										var target = $('#'+ui.draggable.context.id);
										if(target.parent().hasClass('list-layout')){
											$('<li><span>'+target.children().html()+'</span></li>')
												.attr('id',ui.draggable.context.id)
												.addClass('item-draggable item-facultativo')
												.appendTo($(this))
												.draggable({
													cursor: 'move',
													zIndex: 99999,
													revert: 'invalid'
												});
											target.remove();
											resetFormInput('#'+ui.draggable.context.id);
										}
										initListPick();
									}
								});  

								$('.list-layout').droppable({
									accept: '.item-draggable',
									drop: function(event, ui){
										var target = $('#'+ui.draggable.context.id); //adiciona elemento na lista
										
										turnDraggable(target);
										
										var top = ui.position.top;
										var left = ui.position.left;
										if(target.parent().hasClass('list-pick') || target.parent().hasClass('list-pick-facultativa')){
											
											var drag_fundo = $('.drag-fundo').width();
											var drag_drop = $('.drag-and-drop').width();
											
											var margin_left_fundo = $('.drag-fundo').css('margin-left');
											var margin_left_pick = $('.drag-pick').css('margin-left');
											var padding_left_fundo = $('.drag-fundo').css('padding-left');
											var padding_left_pick = $('.drag-pick').css('padding-left');

											var soma_margin = parseInt(margin_left_fundo)+parseInt(margin_left_pick);
											var soma_padding = parseInt(padding_left_fundo)+parseInt(padding_left_pick);

											var delta = drag_drop - drag_fundo - soma_padding - soma_margin;
											
											if(target.parent().hasClass('list-pick')){
												left = left - delta;
												top = top + posicoes_required[ui.draggable.context.id].top;
											}else if(target.parent().hasClass('list-pick-facultativa')){
												left = left-delta+posicoes_facultativa[ui.draggable.context.id].left;
												top=top+posicoes_facultativa[ui.draggable.context.id].top;
											}


										}

										target.css({top: top, left: left, position:'absolute'});
										target.appendTo($(this));
										initListPick();
										setAttributosFont();

										// seta inputs que armazenam configurações do target  
										$('#'+ui.draggable.context.id+'_posx').val(parseInt(left));
										$('#'+ui.draggable.context.id+'_posy').val(parseInt(top+target.height()));
										if(ui.draggable.context.id === 'foto' || ui.draggable.context.id === 'qr-code'){
											$('#'+ui.draggable.context.id+'_posy').val(parseInt(top));

											$('#'+ui.draggable.context.id+'_width').val(parseInt(target.css('width')));
											$('#'+ui.draggable.context.id+'_height').val(parseInt(target.css('height')));

											target.resizable({
												resize: function(event, ui){
													$('.'+ui.element.context.id)
													.css('height', ui.size.height)
													.css('width', ui.size.width);

													$('#'+ui.element.context.id+'_width').val(ui.size.width);
													$('#'+ui.element.context.id+'_height').val(ui.size.height);
												}
											});
										}
									}
								});

								$('.list-pick li, .list-pick-facultativa li').draggable({
									cursor: 'move',
									zIndex: 99999,
									revert: 'invalid'
								});

								// seta posicoes dos draggables sobre o layout
								function setLayoutDraggables(){
									$('.form-inputs div').each(function(index, element){
										var id = '#'+element.id.replace('_inputs','').trim();
										var left = $(id+'_posx').val();
										var top = $(id+'_posy').val();
										var target = $(id);
										
										top = top - target.height();
										if(left !== '' && top !== ''){
											var options = {}
											if(id === '#foto' || id === '#qr-code'){ // seta largura e altura
												top = top + target.height();
												var width = $(id+'_width').val();
												var height = $(id+'_height').val();
												if(width !== '' && height !== ''){
													target.height(height).width(width);
													
													target.resizable({
														resize: function(event, ui){
															$('.'+ui.element.context.id)
															.css('height', ui.size.height)
															.css('width', ui.size.width);

															$('#'+ui.element.context.id+'_width').val(ui.size.width);
															$('#'+ui.element.context.id+'_height').val(ui.size.height);
														}
													});
												}	
											}

											turnDraggable(target);
											
											target.appendTo($('.list-layout'));
											target.css({top: top+'px', left: left+'px', position:'absolute'});											
										}
									});
								}

								function turnDraggable(target){
									
									var options = {}  // torna elemento draggable
									if(target.hasClass('item-required')){
										options = {containment: '#layout', revert: 'invalid', cursor: 'move'}
									}else{
										options = {revert: 'invalid',zIndex: 99999, cursor: 'move'}
									}
									target.draggable(options);
									
									target.on('drag', function(event, ui){
										var target = $('#'+ui.helper.context.id);
										if(target.hasClass('item-facultativo') && ui.position.left < 0){
											$('.drag-fundo').css({overflow: 'visible'});
										}else{
											$('.drag-fundo').css({overflow: 'scroll'});
										}
									});
								}

								$('form').submit(function(event){
									var length = $('.list-pick .item-required').length;
									if(length > 0){
										alert('Há itens obrigatórios (*) não posicionados no layout!');
										event.preventDefault();
									}
								});

								$('#layout_carteirinha_font_name_input').change(function(){
									setFontNameAndFamily();
								});

								$('#layout_carteirinha_font_family_input').change(function(){
									setFontNameAndFamily();	
								});

								$('#layout_carteirinha_tamanho_fonte').change(function(){
									setFontSize();
								});

								$('#layout_carteirinha_font_color_input').change(function(){
									setFontColor();
								});

								$('#layout_carteirinha_font_weight_input').change(function(){
									setFontWeight();	
								});

								$('#layout_carteirinha_font_style_input').change(function(){
									setFontStyle();
								});

								$('#layout_carteirinha_font_box_input').change(function(){
									setFontBox();
								});

								function setAttributosFont(){
									setFontSize();
									setFontNameAndFamily();
									setFontColor();
									setFontWeight();
									setFontStyle();
									setFontBox();
								}

								function setFontSize(){
									var size = $('#layout_carteirinha_tamanho_fonte').val();
									if( size !== ''){										
										$('.list-layout .item-draggable > span').css('font-size', size+'px');
										$('.list-layout li').each(function(index, element){
											var item = $('#'+element.id);
											if (element.id !== 'foto' && element.id != 'qr-code'){
												item.height(size+'px').width('auto');
											}
										});										
									}
								}

								function setFontNameAndFamily(){
									var name = $('#layout_carteirinha_font_name').val();
									var family = $('#layout_carteirinha_font_family').val();
									var font_name = 'Arial,Arial,serif';
									if(name != ''){
										font_name = font_name.replace('Arial',name);
									}
									if(family != ''){
										font_name = font_name.replace('serif',name);
									}
									$('.list-layout .item-draggable > span:first-child')
										.css('font-family', font_name);
								}

								function setFontColor(){
									var color = $('#layout_carteirinha_font_color').val();
									if(color !== ''){
										$('.list-layout .item-draggable > span:first-child')
											.css('color', color);
									}
								}

								function setFontWeight(){
									var weight = $('#layout_carteirinha_font_weight option:selected').html();
									if(weight !== ''){
										if(weight == 'all'){
											weight = 'normal';
										}
										$('.list-layout .item-draggable > span:first-child')
											.css('font-weight', weight);
									}
								}

								function setFontStyle(){
									var style = $('#layout_carteirinha_font_style option:selected').html();
									if(style !== ''){
										if(style == 'all'){
											style = 'normal';
										}
										$('.list-layout .item-draggable > span:first-child')
											.css('font-style', style);
									}
								}

								function setFontBox(){
									var box = $('#layout_carteirinha_font_box').val();
									console.log(box);
									if(box !== ''){
										
										inputs = ['nome','instituicao-ensino','curso', 'escolaridade'];
										$.each(inputs, function(index, value){
											var target = $('#'+value).children().first();
											if(target.parent().parent().hasClass('list-layout')){
												var html = target.html();
												switch(box){
													case 'caixabaixa':
														target.css('text-transform','lowercase');
													break;
													case 'titularizado':
														target.css('text-transform','capitalize');
													break;
													default: // Caixaalta
														target.css('text-transform','uppercase');
												}
											}
										});
									}
								}

								function readURL(input) {
							        if (input.files && input.files[0]) {
							            var reader = new FileReader();
							            reader.onload = function (e) {
							                $('#layout').attr('src', e.target.result);

							            }
							            reader.onloadend = function(e){
							            	resizeListLayout();
							            }
							            reader.readAsDataURL(input.files[0]);
							        }
							    }

							    function resizeListLayout(){
							    	var layout = $('#layout');
							    	$('.list-layout').width(layout.width()).height(layout.height());
							    }

							    $('#layout_carteirinha_anverso').change(function(){
							        readURL(this);
							    });
							});	
							</script>"
		end
end