# encoding: utf-8

require 'nokogiri'
require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/xmimodel/xmihelper.rb')

class XmiHelperTest < Test::Unit::TestCase

	def setup
		@models = [XmiModel.new("./test/resource/MagicDraw/escola.xml")]
	end

	def test_action_states
		#puts __method__
		@models.each do |model|
			activity_graph = XmiHelper.activity_graph_by_name(model.document, 'IncluirAlunoAD')
			action_states = XmiHelper.action_states(activity_graph)
			# 'Carregar Dados', 'Dados do Aluno', 'Salvar'
			assert_equal(action_states.size, 3)
		end
	end

	def test_activity_graph_by_name
		#puts __method__
		@models.each do |model|
			activity_graph = XmiHelper.activity_graph_by_name(model.document, 'IncluirAlunoAD')
			assert_not_nil(activity_graph)
			activity_graph = XmiHelper.activity_graph_by_name(model.document, 'ConsultarAlunoAD')
			assert_not_nil(activity_graph)
		end
	end

	def test_activity_graphs
		#puts __method__
		@models.each do |model|
			use_case = XmiHelper.use_case_by_name(model.document, 'IncluirAlunoUC')
			activity_graphs = XmiHelper.activity_graphs(use_case)
			# 'IncluirAlunoAG'
			assert_equal(activity_graphs.size, 1)			
		end
	end	

	def test_all_associations
		#puts __method__
		@models.each do |model|
			associations = XmiHelper.all_associations(model.document)			
			# Aluno -> Disciplia
			# Professor -> Disciplina
			# Pessoa - Telefone (2x)
			assert_equal(associations.size, 4)
		end
	end

	def test_all_generalizations
		#puts __method__
		@models.each do |model|			
			generalizations = XmiHelper.all_generalizations(model.document)			
			# Aluno -> Pessoa
			# Professor -> Pessoa
			assert_equal(generalizations.size, 2)
		end		
	end

	def test_all_packages
		#puts __method__
		@packages = [	
				"br",
				"escola",
				"domain",
				"enumeration",
				"view",
				"Component View",
				"Data types"
		]
		@models.each do |model|			
			all_packages = XmiHelper.all_packages(model.document)			
			assert(all_packages.size == @packages.size, "O número de pacotes deve ser #{@packages.size} mas foram encontrados #{all_packages.size}.")
			@packages.each do |package|
				achou = false
				all_packages.each do |uml_package|
					if uml_package.attribute("name").to_s.eql? package
						achou = true
						break
					end
				end
				assert(achou, "Não encontrou o pacote \"#{package}\"")
			end
		end		
	end

	def test_associations
		#puts __method__
		@models.each do |model|
			package_domain = XmiHelper.package_by_full_name(model.document, "br.escola.domain")
			associations = XmiHelper.associations(package_domain)			
			assert_equal(associations.size, 4)
		end		
	end

	def test_associations_by_participant_id
		#puts __method__
		@models.each do |model|
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Disciplina")
			id = clazz.attribute("xmi.id")
			associations = XmiHelper.associations_by_participant_id(model.document, id)			
			# Aluno -> Disciplia
			# Professor -> Disciplina			
			assert_equal(associations.size, 2)
		end			
	end

	def test_associations_by_participant_id
		#puts __method__
		@models.each do |model|
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Disciplina")
			id = clazz.attribute("xmi.id")
			associations = XmiHelper.associations_by_participant_id(model.document, id)			
			# Aluno -> Disciplia
			# Professor -> Disciplina			
			assert_equal(associations.size, 2)
		end			
	end

	def test_attributes
		#puts __method__
		@models.each do |model|
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Aluno")
			attributes = XmiHelper.attributes(clazz)		
			# matricula, ativo
			assert_equal(attributes.size, 2)
		end
	end	

	def test_attribute_by_id
		#puts __method__
		@models.each do |model|
			
			# matricula
			id = "_9_5_1_daa0248_1355488512661_251650_4"
			attribute = XmiHelper.attribute_by_id(model.document, id)		
			assert_not_nil(attribute)
			
			# nome (Disciplina)
			id = "_9_5_1_daa0248_1355767817334_23553_140"
			attribute = XmiHelper.attribute_by_id(model.document, id)		
			assert_not_nil(attribute)

			# nil
			id = "0"
			attribute = XmiHelper.attribute_by_id(model.document, id)		
			assert_nil(attribute)
		end
	end	

	def test_attribute_by_name
		#puts __method__
		@models.each do |model|

			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Aluno")
			assert_not_nil(clazz)

			attribute = XmiHelper.attribute_by_name(clazz, "matricula")		
			assert_not_nil(attribute)
			
			attribute = XmiHelper.attribute_by_name(clazz, "ativo")		
			assert_not_nil(attribute)

			attribute = XmiHelper.attribute_by_name(clazz, "fasdaf")		
			assert_nil(attribute)
		end
	end

	def test_attribute_initial_value
		#puts __method__
		@models.each do |model|
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Pessoa")			
			attribute = XmiHelper.attribute_by_name(clazz, "sexo")	
			value = XmiHelper.attribute_initial_value(attribute)
			assert_equal(value, "M")
		end
	end

	def test_xmi_content
		#puts __method__
		@models.each do |model|			
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Telefone")
			xmi_content = XmiHelper.xmi_content(clazz)
			assert_equal(xmi_content.class, Nokogiri::XML::Element)
			assert_equal(xmi_content.name, "XMI.content")

			attribute = XmiHelper.attribute_by_name(clazz, "numero")
			xmi_content = XmiHelper.xmi_content(attribute)
			assert_equal(xmi_content.class, Nokogiri::XML::Element)
			assert_equal(xmi_content.name, "XMI.content")

			xmi_content = XmiHelper.xmi_content(model.document)
			assert_equal(xmi_content.class, Nokogiri::XML::Element)
			assert_equal(xmi_content.name, "XMI.content")
		end		
	end

	def test_attribute_type
		#puts __method__
		@models.each do |model|		
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Telefone")
			attribute = XmiHelper.attribute_by_name(clazz, "numero")
			type = XmiHelper.attribute_type(attribute)
			assert_not_nil(type)
		end		
	end

	def test_attribute_type_name
		#puts __method__
		@models.each do |model|		
			clazz = XmiHelper.class_by_full_name(model.document, "br.escola.domain.Telefone")
			attribute = XmiHelper.attribute_by_name(clazz, "numero")
			type = XmiHelper.attribute_type_name(attribute)
			assert_not_nil(type)
		end		
	end	

end