# encoding: utf-8
require 'nokogiri'

##
# A helper for working with XMI files.
#
# Author::    Marcus Siqueira  (mailto:marvinsiq@gmail.com)
# License::   Distributes under the same terms as Ruby
class XmiHelper

	# Constructor.
	def initialize
	end

	##
	# Get all the Action State in the tag.
	#
	# Action State is a representation of an action on a Activity Graph.
	#
	# The parameter 'tag' needs be a Nokogiri::XML::Element of type 'UML:ActivityGraph'.
	#
	# Returns an array of objects Nokogiri::XML::Element of type 'UML:ActionState'.
	#
	# See also:
	# * call_events		
	def self.action_states(tag)
		raise ArgumentError.new("Parameter is not a UML:ActivityGraph.") if tag.nil? || tag.name != "ActivityGraph"
		tag.xpath('./UML:StateMachine.top/UML:CompositeState/UML:CompositeState.subvertex/UML:ActionState')		
	end

	##
	# Get the Activity Graph by name.
	#
	# The parameter 'document' can be any Nokogiri::XML::Element of model.
	#
	# The parameter 'name' cannot be empty.
	#
	# Returns a object Nokogiri::XML::Element of type 'UML:ActivityGraph'.
	def self.activity_graph_by_name(document, name)
		tag_by_name(xmi_content(document), "UML:ActivityGraph", name)
	end	

	##
	# Get all the Activity Graphs in the tag.
	#
	# The parameter 'tag' can be any Nokogiri::XML::Element that contains the tag 'UML:Namespace.ownedElement'.
	#
	# Returns a object Nokogiri::XML::Element of type 'UML:ActivityGraph'.
	def self.activity_graphs(tag)
		namespace(tag).xpath('./UML:ActivityGraph')
	end	

	##
	# Get all the Associations in the model.
	#
	# The parameter 'tag' can be any Nokogiri::XML::Element of model.
	#
	# Returns an array of all objects Nokogiri::XML::Element of type 'UML:Association'.
	def self.all_associations(tag)
		xmi_content(tag).xpath("//UML:Association")
	end	

	##
	# Get all the Generalizations in the model.
	#
	# The parameter 'tag' can be any Nokogiri::XML::Element of model.
	#
	# Returns an array of all objects 'Nokogiri::XML::Element' of type 'UML:Generalization'.
	def self.all_generalizations(tag)		
		xmi_content(tag).xpath('//UML:Namespace.ownedElement/UML:Generalization')
	end

	##
	# Get all the Packages in the model.
	#
	# The parameter 'tag' can be any Nokogiri::XML::Element of model.
	#
	# Returns an array of all objects 'Nokogiri::XML::Element' of type 'UML:Package'.
	def self.all_packages(tag)
		xmi_content(tag).xpath('//UML:Namespace.ownedElement/UML:Package')
	end

	##
	# Get all the Associations in the model.
	#
	# The parameter 'tag' can be any Nokogiri::XML::Element that contains the tag 'UML:Namespace.ownedElement'.
	#
	# Returns an array of objects 'Nokogiri::XML::Element' of type 'UML:Association'.
	def self.associations(tag)
		namespace(tag).xpath("./UML:Association")
	end

	##
	# Get the Associations by id of the any participants of relationship.
	#
	# The parameter 'tag' can be any Nokogiri::XML::Element of model.
	#
	# Returns an array of objects 'Nokogiri::XML::Element' of type 'UML:Association'.
	def self.associations_by_participant_id(tag, id)
		
		associations = Array.new

		xmi_content(tag).xpath('//UML:Association').each do |a|

			a.xpath( "./UML:Association.connection/UML:AssociationEnd").each do |ae|
				participant_id = participant_id_by_association_end(ae)

				if (!participant_id.nil?) && participant_id.to_s.eql?(id.to_s) && !associations.include?(a)
					associations << a 
				end
			end	
		end

		return associations		
	end

	# 
	# Get the attributes of a class.
	#
	# Returns an array of objects 'Nokogiri::XML::Element' of type UML:Attribute
	def self.attributes(uml_class)
		uml_class.xpath('./UML:Classifier.feature/UML:Attribute')
	end

	# 
	# Get the attribute of a class by identification
	#
	# Returns a object 'Nokogiri::XML::Element' of type UML:Attribute
	def self.attribute_by_id(document, id)
		type = tag_by_id(document, 'UML:Attribute', id)
	end

	# 
	# Get the attribute of a class by name
	#
	# Returns a object 'Nokogiri::XML::Element' of type UML:Attribute
	def self.attribute_by_name(uml_class, name)
		tag_by_name(uml_class, "UML:Attribute", name)
	end	

	# 
	# Get the initial value of an attribute
	# 
	# Returns a String with the value
	def self.attribute_initial_value(uml_attribute)
		raise ArgumentError.new("Parameter is not a UML:Attribute tag.") if uml_attribute.name != "Attribute"
		uml_expression = uml_attribute.at_xpath('./UML:Attribute.initialValue/UML:Expression')
		
		if uml_expression.nil?
			return ''
		else 
			return uml_expression.attribute('body').to_s.strip
		end
	end

	# 
	# Return a object 'Nokogiri::XML::Element' of type 'UML:Class' or 'UML:DataType' or a String
	def self.attribute_type(uml_attribute)
		raise ArgumentError.new("Parameter is not a 'UML:Attribute' tag.") if uml_attribute.name != "Attribute"
		type = uml_attribute.attribute('type').to_s
		# Se não possuir o atributo tipo, verifica se possui a tag abaixo com o tipo primitivo		
		if type.nil? || type.empty?
			uml_type = uml_attribute.at_xpath('./UML:StructuralFeature.type/UML:Classifier/XMI.extension/referentPath')
			type = uml_type.attribute('xmi.value').to_s unless uml_type.nil?
		else
			id = type
			xmi_content = xmi_content(uml_attribute)
			
			clazz = class_by_id(xmi_content, id)
			return clazz unless clazz.nil?

			enum = enumeration_by_id(xmi_content, id)
			return enum unless enum.nil?

			data_type = data_type(xmi_content, id)
			return data_type unless data_type.nil?
		end		
		type
	end

	def self.attribute_type_name(uml_attribute)
		type = attribute_type(uml_attribute)
		return nil if type.nil?
		return type if type.class.to_s.eql?("String")
		if type.class.to_s.eql?("Nokogiri::XML::Element") 
			return type.attribute("name").to_s if type.name == "DataType"
			return full_class_name(type) if type.name == "Class"
			return full_enumeration_name(type) if type.name == "Enumeration"
		end
		nil
	end

	# 
	# Call Events are links between ActionStates (by deferrableEvent propertie) and Operations (methods of a class).
	#
	# Call Events are actions triggered by a state.
	#
	# See:
	# * action_states
	# * operations
	# * signal_events	
	def self.call_events(tag)
		namespace(tag).xpath("./UML:CallEvent")		
	end	

	def self.class_by_full_name(document, full_name)

		class_name = full_name.split(".").last
		package_name = full_name.clone
		package_name["." + class_name] = ""

		package_xml = package_by_full_name(xmi_content(document), package_name)
		package_xml.at_xpath("./UML:Namespace.ownedElement/UML:Class[@name='#{class_name}']")

	end		

	def self.class_by_id(document, id)
		tag_by_id(document, 'UML:Class', id)
	end

	def self.class_by_name(document, name)
		tag_by_name(xmi_content(document), "UML:Class", name)
	end

	def self.classes(tag)
		namespace(tag).xpath("./UML:Class")
	end

	def self.classes_by_association(document, association)		
		raise ArgumentError.new("Parameter is not a UML:Association tag.") if association.name != 'Association'

		classes = Array.new

		association.xpath( "./UML:Association.connection/UML:AssociationEnd").each do |ae|
			participant_id = participant_id_by_association_end(ae)
			clazz = class_by_id(xmi_content(document), participant_id) unless participant_id.nil? 
			classes << clazz unless clazz.nil?
		end

		classes
	end

	def self.data_type(document, id)
		tag_by_id(document, 'UML:Enumeration', id)
	end

	def self.data_types(tag)
		namespace(tag).xpath("./UML:DataType")		
	end	

	def self.enumeratios(tag)
		namespace(tag).xpath("./UML:Enumeration")
	end

	def self.enumeration_by_id(document, id)
		tag_by_id(document, 'UML:DataType', id)
	end	

	def self.exporter(document)
		@exporter = document.at_xpath("./XMI/XMI.header/XMI.documentation/XMI.exporter").inner_html
	end

	def self.exporter_version(document)
		@exporter_version = document.at_xpath("./XMI/XMI.header/XMI.documentation/XMI.exporterVersion").inner_html
	end	
		
	def self.metamodel_version(document)
		@metamodel_version = doc.at_xpath("./XMI/XMI.header/XMI.metamodel").attribute("xmi.version").to_s	
	end

	def self.extension_referent_path_value(tag)
		return "" if tag.nil?

		if tag.name != 'XMI.extension'
			tag = tag.at_xpath("./XMI.extension")
		end
		return "" if tag.nil?

		raise ArgumentError.new("Parameter is not a XMI.extension tag or a tag that contains.") if tag.name != 'XMI.extension'
		
		referent_path = tag.at_xpath("./referentPath")
		if referent_path.nil?
			return ""
		else
			return referent_path.attribute("xmi.value").to_s
		end
	end

	def self.has_namespace?(tag) 
		return false if tag.nil?
		if tag.name != "Namespace.ownedElement"
			tag = tag.at_xpath("./UML:Namespace.ownedElement")
		end
		if tag.nil? or tag.name != "Namespace.ownedElement"
			return false
		end
		return true
	end	

	def self.namespace(tag)
		raise ArgumentError.new("Parameter cannot be nil..") if tag.nil?
		if tag.name != "Namespace.ownedElement"
			tag = tag.at_xpath("./UML:Namespace.ownedElement")
		end
		if tag.nil? or tag.name != "Namespace.ownedElement"
			raise ArgumentError.new("Parameter does not contain a tag 'UML:Namespace.ownedElement'.")
		end
		tag	
	end

	def self.full_class_name(clazz)
		raise ArgumentError.new("Parameter cannot be nil..") if clazz.nil?
		package = parent_package(clazz)
		if package.nil?
			clazz.attribute("name") 
		else
			full_package_name(package) + "." + clazz.attribute("name")
		end
	end

	def self.full_enumeration_name(enumeration)
		raise ArgumentError.new("Parameter cannot be nil..") if enumeration.nil?
		package = parent_package(enumeration)
		if package.nil?
			enumeration.attribute("name") 
		else
			full_package_name(package) + "." + enumeration.attribute("name")
		end
	end	

	def self.full_package_name(package)
		
		name = package.attribute("name").to_s
		begin
			package = parent_package(package)

			name = package.attribute("name").to_s + "." + name unless package.nil?
		end while !package.nil?

		name
	end

	def self.generalization_by_child(document, id)
		
		xmi_content(document).xpath('//UML:Generalization').each do |g|
			child = g.attribute('child')
			if child.nil?
				class_ref = g.at_xpath('./UML:Generalization.child/UML:Class')
				child = class_ref.attribute('xmi.idref') unless class_ref.nil?
			end

			return g if !child.nil? && id == child.to_s
		end

		nil
	end

	# 
	# Returns the child id from the tag 'UML:Generalization'
	def self.generalization_child(generalization)
		child = generalization.attribute("child")
		if child.nil?
			class_ref = generalization.at_xpath('./UML:Generalization.child/UML:Class')
			child = class_ref.attribute('xmi.idref') unless class_ref.nil?
		end
		child.to_s
	end

	# 
	# Returns the parent id from the tag 'UML:Generalization'
	def self.generalization_parent(generalization)
		parent = generalization.attribute("parent")
		if parent.nil?
			class_ref = generalization.at_xpath('./UML:Generalization.parent/UML:Class')
			parent = class_ref.attribute('xmi.idref') unless class_ref.nil?
		end
		parent.to_s
	end

	def self.guard_condition(tag)
		
		return nil if tag.nil?
		if tag.name == "Transition"
			tag = tag.at_xpath("./UML:Transition.guard/UML:Guard")
		end

		return nil if tag.nil?
		raise ArgumentError.new("Parameter is not a UML:Guard OR UML:Transition tag.") if tag.name != "Guard"	
		tag.at_xpath('./UML:Guard.expression/UML:BooleanExpression')
	end

	def self.metamodel_version(document)
		@metamodel_version = document.at_xpath("./XMI/XMI.header/XMI.metamodel").attribute("xmi.version").to_s	
	end	

	def self.package_by_name(tag, package_name)

		# se passou um 'UML:Package' navega até o 'UML:Namespace.ownedElement' filho
		if tag.name == "Package"
			tag = tag.at_xpath("./UML:Namespace.ownedElement")
		end

		# deverá ser 'UML:Namespace.ownedElement' ou 'XMI.content'
		if !(tag.nil?) && (tag.name == "Namespace.ownedElement" || tag.name == "XMI.content")

			# procura pelo pacote
			tag.xpath('./UML:Package').each do |package|
				return package if package.attribute('name').to_s == package_name
			end

			# poderá ter uma tag './UML:Model' com mais 'UML:Namespace.ownedElement'
			tag.xpath("./UML:Model").each do |model|
		
				model.xpath('./UML:Namespace.ownedElement').each do |namespace|

					# procura recursivamente dentro do namespace
					p = package_by_name(namespace, package_name)
					return p unless p.nil?
				end	
			end

		end
		nil
	end

	def self.package_by_full_name(document, full_package_name)
		package_name = full_package_name.split(".")

		if package_name.length >= 1
			package = package_by_name(xmi_content(document), package_name[0])

			for i in 1..package_name.length - 1
				return nil if (package == nil)

				package = package_by_name(package, package_name[i])
			end
			return package
		end

		nil
	end

	def self.packages(tag)

		packages = Array.new

		if tag.name == "XMI.content"
			tag = tag.at_xpath('./UML:Model/UML:Namespace.ownedElement')

		# se passou um 'UML:Package' navega até o 'UML:Namespace.ownedElement' filho
		elsif tag.name == "Package" || tag.name == "Model"
			tag = tag.at_xpath("./UML:Namespace.ownedElement")
		end	

		# Pacote sem nenhuma classe nem pacotes internos
		return packages if tag.nil?

		# deverá ser 'UML:Namespace.ownedElement' ou 'XMI.content'
		if tag.name == "Namespace.ownedElement" || tag.name == "XMI.content"

			tag.xpath('./UML:Package').each do |package|
				# puts package.attribute "name"
				packages << package
			end
		end

		if packages.size == 0
			tag.xpath('./UML:Model').each do |model|
				packages = packages + XmiHelper.packages(model)
			end
		end

		packages
	end

	def self.parameters(tag)
				
		if tag.name == "SignalEvent"			
			tag.xpath("./UML:Event.parameter/UML:Parameter")
		elsif tag.name == "Operation" 
			tag.xpath("./UML:BehavioralFeature.parameter/UML:Parameter")			
		else
			raise ArgumentError.new("Parameter (#{tag.name}) is not a UML:SignalEvent or UML:Operation tag.") 
		end		
	end	

	def self.parent_package(tag)

		return nil if tag.nil?

		if tag.name == "Class" || tag.name == "Package" ||  tag.name == "Enumeration" 
			namespace = tag.parent if !(tag.parent.nil?) && tag.parent.name == "Namespace.ownedElement"			
		end
		
		if !namespace.nil?			
			return namespace.parent if !(namespace.parent.nil?) && namespace.parent.name == "Package"
		end
		nil
	end

	def self.participant_id_by_association_end(association_end)

		raise ArgumentError.new("Parameter is not a AssociationEnd tag.") if association_end.name != 'AssociationEnd'

		if association_end.attribute("participant").nil?

			if association_end.attribute("type").nil?
				participant_id = association_end.at_xpath("./UML:AssociationEnd.participant/UML:Class")
				part = participant_id.attribute('xmi.idref') unless participant_id.nil?
			else
				part = association_end.attribute("type")
			end
		else
			part = association_end.attribute("participant")
		end

		return part
	end

	def self.stereotypes(document)

		stereotypes = Array.new
		document.xpath('./UML:ModelElement.stereotype/UML:Stereotype').each do |stereotype|
			stereotypes << stereotype
		end
		stereotypes
	end

	def self.stereotype_by_href(document, href)
		stereotype = document.at_xpath("//UML:Stereotype[@href='#{href}']")
	end

	def self.stereotype_by_id(document, id)
		tag_by_id(document, 'UML:Stereotype', id)
	end	

	def self.xmi_content(tag)
		return tag if tag.nil? or tag.name == "XMI.content"
		xmi_content = tag.document.at_xpath("./XMI/XMI.content")
	end	

	def self.tag_definition_by_id(document, id)
		tag_by_id(document, 'UML:TagDefinition', id)
	end

	def self.tagged_values(tag)
		t = Array.new
		tag.xpath('./UML:ModelElement.taggedValue/UML:TaggedValue').each do |tagged_value|
			t << tagged_value
		end
		t
	end

	def self.tagged_value_by_name(tag, name)
		tag_by_name(tag, "UML:TaggedValue", name)
	end

	def self.taggeg_value_data_value(tag)
		return "" if tag.nil?

		if tag.name == 'TaggedValue'
			#tag_id = tag.attribute("xmi.id").to_s
			tag = tag.at_xpath("./UML:TaggedValue.dataValue")
		end

		if tag.nil?
			#puts "[WARN] - TaggedValue '#{tag_id}' sem tag UML:TaggedValue.dataValue"
			return ""
		end

		raise ArgumentError.new("Parameter is not a UML:TaggedValue.dataValue tag or a tag that contains.") if tag.name != 'TaggedValue.dataValue'

		tag.inner_html
	end

	# TaggedValue
	def self.taggeg_value_reference_value(tag)
		return "" if tag.nil?
		raise ArgumentError.new("Parameter is not a UML:TaggedValue tag.") if tag.name != 'TaggedValue'
		tag = tag.at_xpath("./UML:TaggedValue.referenceValue/UML:ModelElement/XMI.extension")
		extension_referent_path_value(tag)
	end

	def self.taggeg_value_tag_definition(tag)
		return "" if tag.nil?
		raise ArgumentError.new("Parameter is not a UML:TaggedValue tag.") if tag.name != 'TaggedValue'
		tag = tag.at_xpath("./UML:TaggedValue.type/UML:TagDefinition")
	end

	# Signal events are methods triggered between one state and another
	def self.signal_events(tag)
		namespace(tag).xpath("./UML:SignalEvent")
	end

	def self.use_case_by_name(document, name)
		tag_by_name(xmi_content(document), "UML:UseCase", name)
	end	

	def self.use_cases(tag)
		namespace(tag).xpath("./UML:UseCase")		
	end

	def self.multiplicity(tag)
		return nil if tag.nil?

		case tag.name
		
		when "Attribute"
			uml_multiplicity = tag.at_xpath('./UML:StructuralFeature.multiplicity/UML:Multiplicity')

		when "AssociationEnd"
			uml_multiplicity = tag.at_xpath('./UML:AssociationEnd.multiplicity/UML:Multiplicity')
		else
			raise ArgumentError.new("Parameter is not a UML:Attribute or UML:AssociationEnd tag.") 
		end

		uml_multiplicity
	end

	def self.multiplicity_range(tag)

		return nil if tag.nil?

		tag = multiplicity(tag) if (tag.name == "Attribute" || tag.name == "AssociationEnd")
		return nil if tag.nil?

		raise ArgumentError.new("Parameter is not a UML:Multiplicity tag.") if tag.name != "Multiplicity"		

		uml_multiplicity_range = tag.at_xpath('./UML:Multiplicity.range/UML:MultiplicityRange')
		
		if uml_multiplicity_range.nil?
			return nil
		else 
			return [Integer(uml_multiplicity_range.attribute('lower').to_s), Integer(uml_multiplicity_range.attribute('upper').to_s)]
		end
	end	

	def self.operations(uml_class)
		raise ArgumentError.new("Parameter is not a UML:Class tag.") if uml_class.name != "Class"

		uml_class.xpath('./UML:Classifier.feature/UML:Operation')		
	end	

	def self.operation_by_id(document, id)
		tag_by_id(document, 'UML:Operation', id)
	end

	def self.operation_by_name(tag, name)
		raise ArgumentError.new("Parameter is not a UML:Class tag.") if tag.nil? || tag.name != "Class"
		tag.at_xpath("./UML:Classifier.feature/UML:Operation[@name='#{name}']")
	end	

	def self.pseudo_states(tag)
		raise ArgumentError.new("Parameter is not a UML:ActivityGraph tag.") if tag.nil? || tag.name != "ActivityGraph"
		tag.xpath('./UML:StateMachine.top/UML:CompositeState/UML:CompositeState.subvertex/UML:Pseudostate')
	end

	def self.final_states(tag)
		raise ArgumentError.new("Parameter is not a UML:ActivityGraph tag.") if tag.nil? || tag.name != "ActivityGraph"
		tag.xpath('./UML:StateMachine.top/UML:CompositeState/UML:CompositeState.subvertex/UML:FinalState')		
	end

	def self.transitions(tag)
		raise ArgumentError.new("Parameter is not a UML:ActivityGraph tag.") if tag.nil? || tag.name != "ActivityGraph"
		tag.xpath('./UML:StateMachine.transitions/UML:Transition')				
	end

	def self.version
		"1.0.0"
	end

	private

	def self.tag_by_name(document, tag, name)
		raise ArgumentError.new("Parameter 'name' cannot be empty.") if name.nil? or name.empty?
		use_case = xmi_content(document).at_xpath("//#{tag}[@name='#{name}']")
	end

	def self.tag_by_id(document, tag, id)
		raise ArgumentError.new("Parameter 'id' cannot be empty.") if id.nil? or id.empty?
		use_case = xmi_content(document).at_xpath("//#{tag}[@xmi.id='#{id}']")
	end
end