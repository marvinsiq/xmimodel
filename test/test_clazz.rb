# encoding: utf-8

require 'nokogiri'
require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/xmimodel/xmihelper.rb')

class ClazzTest < Test::Unit::TestCase

	def setup

		@magic_draw = XmiModel.new("./test/resource/MagicDraw/escola.xml")
		@argo = XmiModel.new("./test/resource/argoUML/escola.xmi")

		@models = [@magic_draw, @argo]


		aluno = {
			"name" => "Aluno",
			"package" => "br.escola.domain",
			"attributes" => ["br.escola.domain.Aluno::matricula", "br.escola.domain.Aluno::ativo"],
			"stereotypes" => ["Entity"],
			"tagged_values" => ["@javax.persistence.Table.name=aluno", "@java.lang.Deprecated=false"],
			"operations" => ["br.escola.domain.Aluno::matricular"],
			"children" => [],
			"parent" => "br.escola.domain.Pessoa"
		}

		disciplina = {
			"name" => "Disciplina",
			"package" => "br.escola.domain",
			"attributes" => ["br.escola.domain.Disciplina::nome"],
			"stereotypes" => ["Entity"],
			"tagged_values" => [],
			"operations" => [],
			"children" => [],
			"parent" => nil			
		}

		pessoa = {
			"name" => "Pessoa",
			"package" => "br.escola.domain",
			"attributes" => ["br.escola.domain.Pessoa::nome",
				"br.escola.domain.Pessoa::dataNascimento",
				"br.escola.domain.Pessoa::sexo",
				"br.escola.domain.Pessoa::cpf"],
			"stereotypes" => ["Entity"],
			"tagged_values" => [],
			"operations" => [],
			"children" => ["br.escola.domain.Aluno", "br.escola.domain.Professor"],
			"parent" => nil			
		}

		professor = {
			"name" => "Professor",
			"package" => "br.escola.domain",
			"attributes" => [],
			"stereotypes" => ["Entity"],
			"tagged_values" => [],
			"operations" => [],
			"children" => [],
			"parent" => "br.escola.domain.Pessoa"
		}

		telefone = {
			"name" => "Telefone",
			"package" => "br.escola.domain",
			"attributes" => ["br.escola.domain.Telefone::tipo",
				"br.escola.domain.Telefone::ddd",
				"br.escola.domain.Telefone::numero"],
			"stereotypes" => ["Entity"],
			"tagged_values" => [],
			"operations" => [],
			"children" => [],
			"parent" => nil
		}

		aluno_consultar = {
			"name" => "AlunoConsultar",
			"package" => "br.escola.view",
			"attributes" => [],
			"stereotypes" => [],
			"tagged_values" => [],
			"operations" => [],
			"children" => [],
			"parent" => nil
		}

		aluno_incluir = {
			"name" => "AlunoIncluir",
			"package" => "br.escola.view",
			"attributes" => [],
			"stereotypes" => [],
			"tagged_values" => [],
			"operations" => ["br.escola.view.AlunoIncluir::carregarDados"],
			"children" => [],
			"parent" => nil
		}		


		@classes = {
			@magic_draw => {
				"_9_5_1_daa0248_1355427807242_364493_4" => aluno,
				"_9_5_1_daa0248_1355767798745_503932_124" => disciplina,
				"_9_5_1_807026c_1356041581178_451218_96" => pessoa,
				"_9_5_1_daa0248_1365445531184_810802_572" => professor,
				"_9_5_1_daa0248_1355941859440_399294_94" => telefone,
				"_9_5_1_daa0248_1366810170015_374035_206" => aluno_consultar,
				"_9_5_1_daa0248_1366809934986_93154_203" => aluno_incluir
			} ,
			@argo => {
				"-64--88-0-116-604eea1c:13bba3c6f81:-8000:0000000000000EDC" =>  aluno,
				"-64--88-0-116-604eea1c:13bba3c6f81:-8000:0000000000000F17" =>  disciplina,
				"-64--88-0-116-604eea1c:13bba3c6f81:-8000:0000000000000EFB" =>  pessoa,
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000EEE"   =>  professor,
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F19"   =>  telefone,
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F29"   =>  aluno_consultar,
				"10--56-37-22-7d6734d:13e7f63d612:-8000:0000000000000F2A"   =>  aluno_incluir
			}			
		}	
	end

	def test_clazz
		@models.each do |model|
			@classes[model].each do |id, class_data|

				clazz = model.class_by_id(id)
				assert_not_nil(clazz, "Não encontrou a classe de id \"#{id}\"")

				assert_equal(class_data["name"], clazz.name, "O nome da classe para o id '#{id}' deve ser #{class_data["name"]}")
				assert_equal(class_data["package"], clazz.package.full_name, "O nome do pacote deve ser #{class_data["package"]}")

				clazz.attributes.each do |obj1|
					achou = false
					class_data["attributes"].each do |obj2|
						if (obj1 == obj2)
							achou = true;
							break;
						end
					end						
					assert(achou, "A classe '#{class_data["name"]}' não deveria possuir o atributo '#{obj1}'.")
				end					
				class_data["attributes"].each do |s|
					assert(clazz.attributes.include?(s), "A classe '#{class_data["name"]}' deve possuir o atributo '#{s}'.")
				end		

				clazz.stereotypes.each do |obj1|
					achou = false
					class_data["stereotypes"].each do |obj2|
						if (obj1 == obj2)
							achou = true;
							break;
						end
					end						
					assert(achou, "A classe '#{class_data["name"]}' não deveria possuir o estereótipo '#{obj1}'.")
				end					
				class_data["stereotypes"].each do |s|
					assert(clazz.stereotypes.include?(s), "A classe '#{class_data["name"]}' deve possuir o estereótipo '#{s}'.")
				end				
				
				clazz.tagged_values.each do |obj1|
					achou = false
					class_data["tagged_values"].each do |obj2|
						if (obj1 == obj2)
							achou = true;
							break;
						end
					end
					assert(achou, "A classe '#{class_data["name"]}' não deveria possuir a Tagged Value '#{obj1}'.")
				end	
				class_data["tagged_values"].each do |tv|
					assert(clazz.tagged_values.include?(tv), "A classe '#{class_data["name"]}' deve possuir a Tagged Value '#{tv}'.")
				end	

				clazz.operations.each do |obj1|
					achou = false
					class_data["operations"].each do |obj2|
						if (obj1 == obj2)
							achou = true;
							break;
						end
					end
					assert(achou, "A classe '#{class_data["name"]}' não deveria possuir a Operation '#{obj1}'.")
				end	
				class_data["operations"].each do |tv|
					assert(clazz.operations.include?(tv), "A classe '#{class_data["name"]}' deve possuir a Operation '#{tv}'.")
				end

				clazz.children.each do |obj1|
					achou = false
					class_data["children"].each do |obj2|
						if (obj1 == obj2)
							achou = true;
							break;
						end
					end					
					assert(achou, "A classe '#{class_data["name"]}' não deveria possuir '#{obj1}' como filha.")
				end
				class_data["children"].each do |c|
					assert(clazz.children.include?(c), "A classe '#{class_data["name"]}' deve possuir '#{c}' como filha.")
				end

				assert_equal(class_data["parent"], clazz.parent.nil? ? nil : clazz.parent.full_name, "A classe pai de '#{class_data["name"]}'' deve ser '#{class_data["parent"]}'.")
			end
		end		
	end

	# TODO
	def test_attribute_by_id		
	end	

	# TODO
	def test_attribute_by_name
	end

	# TODO
	def test_operation_by_name
	end	

	# TODO
	def test_stereotype_by_href	
	end

	# TODO
	def test_tagged_value_by_name
	end

	# TODO
	def test_diff
	end

	# TODO
	def test_eql
	end	

	# TODO
	def test_full_name
	end

	# TODO
	def test_to_s
	end
end