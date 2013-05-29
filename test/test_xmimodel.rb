# encoding: utf-8

require 'nokogiri'
require 'test/unit'
require 'xmimodel'

class XmiModelTest < Test::Unit::TestCase
	
	def setup

		@magic_draw = XmiModel.new("./test/resource/MagicDraw/escola.xml")
		@argo = XmiModel.new("./test/resource/argoUML/escola.xmi")

		@models = [@magic_draw, @argo]

		@packages = [	
				"br",
				"br.escola",
				"br.escola.domain",
				"br.escola.enumeration",
				"br.escola.view"
			]

		@classes = {
			@magic_draw => {
				"_9_5_1_daa0248_1355427807242_364493_4" => "br.escola.domain.Aluno",
				"_9_5_1_daa0248_1355767798745_503932_124" => "br.escola.domain.Disciplina",
				"_9_5_1_807026c_1356041581178_451218_96" => "br.escola.domain.Pessoa",
				"_9_5_1_daa0248_1365445531184_810802_572" => "br.escola.domain.Professor",
				"_9_5_1_daa0248_1355941859440_399294_94" => "br.escola.domain.Telefone",
				"_9_5_1_daa0248_1366810170015_374035_206" => "br.escola.view.AlunoConsultar",
				"_9_5_1_daa0248_1366809934986_93154_203" => "br.escola.view.AlunoIncluir"
				},
			@argo => {
				"-64--88-0-116-604eea1c:13bba3c6f81:-8000:0000000000000EDC" => "br.escola.domain.Aluno",
				"-64--88-0-116-604eea1c:13bba3c6f81:-8000:0000000000000F17" => "br.escola.domain.Disciplina",
				"-64--88-0-116-604eea1c:13bba3c6f81:-8000:0000000000000EFB" => "br.escola.domain.Pessoa",
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000EEE" => "br.escola.domain.Professor",
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F19" => "br.escola.domain.Telefone",
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F29" => "br.escola.view.AlunoConsultar",
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F2A" => "br.escola.view.AlunoIncluir"				
			}		
		}

		@states = {
			@magic_draw => {
				"_9_5_1_daa0248_1366809466657_49257_166" => "Dados do Aluno"
				} ,
			@argo => {
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F30" => "Dados do Aluno"
			}
		}
	end

	def test_classes
		#puts __method__
		@models.each do |model|	
			@classes[model].each do |class_id, class_name|
				assert(model.classes.include?(class_name), "Não encontrou a classe \"#{class_name}\"")
			end
			assert(model.classes.size == @classes[model].size, "O número de classes deve ser #{@classes[model].size} mas foram encontradas #{model.classes.size}.")
		end
	end	

	def test_packages
		#puts __method__
		@models.each do |model|
			assert(model.packages.size == @packages.size, "O número de pacotes deve ser #{@packages.size} mas foram encontrados #{model.packages.size} (#{model.packages}).")
			@packages.each do |package|
				assert(model.packages.include?(package), "Não encontrou o pacote \"#{package}\"")
			end
		end
	end

	# TODO
	def test_states
	end	

	def test_class_by_full_name
		#puts __method__
		@models.each do |model|
			@classes[model].each do |class_id, class_name|
				clazz = model.class_by_full_name(class_name)
				assert_not_nil(clazz, "Não encontrou a classe \"#{class_name}\"")
			end
		end
	end

	def test_class_by_id
		#puts __method__
		@models.each do |model|
			@classes[model].each do |class_id, class_name|
				clazz = model.class_by_id(class_id)
				assert_not_nil(clazz, "Não encontrou a classe de id \"#{class_id}\"")
			end
		end
	end	

	def test_package_by_full_name
		#puts __method__
		@models.each do |model|
			@packages.each do |package_name|
				package = model.package_by_full_name(package_name)
				assert_not_nil(package, "Não encontrou o pacote \"#{package_name}\"")
			end
		end
	end

	def test_state_by_id	
		#puts __method__
		@models.each do |model|
			@states[model].each do |state_id, state_name|
				state = model.state_by_id(state_id)
				assert_not_nil(state, "Não encontrou o estado \"#{state_name}\" de id #{state_id}")
				assert_equal(state.name, state_name)
			end
		end		
	end

end