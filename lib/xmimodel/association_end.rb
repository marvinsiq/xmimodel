# encoding: utf-8

require 'xmimodel/tag'

class AssociationEnd < Tag
	
	# @return [String]
	attr_reader :name

	# @return [String]
	attr_reader :visibility

	# @return [String]
	attr_reader :is_navigable

	# @return [String]
	attr_reader :is_specification

	# @return [String]
	attr_reader :multiplicity_range

	# @return [String]
	attr_reader :ordering

	# @return [String]
	attr_reader :aggregation

	# @return [String]
	attr_reader :target_scope

	# @return [String]
	attr_reader :changeability

	# @return [Array<Stereotype>] Association end stereotypes.
	attr_reader :stereotypes

	# @return [Array<TaggedValue>] Association end tagged values.
	attr_reader :tagged_values

	# @return [Association] Return the parent association of this association end
	attr_reader :association	

	# @return [AssociationEnb] Return the other end of the association
	attr_accessor :other_end	

	# @return [Boolean]
	attr_reader :is_first	
	
	def initialize(xmls, index, parent_tag)		
		super(xmls[index], parent_tag)

		@is_first = index == 0

		@xml_a = xmls[0]
		@xml_b = xmls[1]

		@tag = xmls[index]

		@xmi_model = parent_tag.parent_tag
		@association = parent_tag
	
		@participant_id = @xml.attribute("participant").to_s
		
		if @participant_id.nil? or @participant_id.empty?

			# argoUML
			c = @xml.at_xpath("./UML:AssociationEnd.participant/UML:Class")			
			@participant_id = c.attribute("xmi.idref").to_s unless c.nil?

			classifier = @xml.at_xpath("./UML:AssociationEnd.participant/UML:Classifier")
			if !classifier.nil?
				classifier_href = classifier.attribute("href").to_s
				paramns = classifier_href.split("|")
				puts "TODO: Read id #{paramns[1]} from the model #{paramns[0]}"
			end
			
		end

		@name = @xml.attribute("name").to_s

		if @name.empty?
			@name = index == 0 ? "EndA" : "EndB"
		end

		@visibility = @xml.attribute("visibility").to_s
		@is_navigable = @xml.attribute("isNavigable").to_s
		if "true" == @is_navigable
			@is_navigable = true 
		else
			@is_navigable = false
		end		

		@is_specification = @xml.attribute("isSpecification").to_s

		@ordering = @xml.attribute("ordering").to_s
		@aggregation = @xml.attribute("aggregation").to_s
		@target_scope = @xml.attribute("targetScope").to_s
		@changeability = @xml.attribute("changeability").to_s

		@multiplicity_range = XmiHelper.multiplicity_range(@xml)

		@stereotypes = Array.new
		stereotype_id = @xml.attribute("stereotype").to_s
		if !stereotype_id.empty?
			stereotype = XmiHelper.stereotype_by_id(@xml, stereotype_id)
			stereotype = Stereotype.new(stereotype, self)
			@stereotypes << stereotype			
		end
		XmiHelper.stereotypes(@xml).each do |uml_stereotype|
			stereotype = Stereotype.new(uml_stereotype, self)
			@stereotypes << stereotype
		end	

		@tagged_values = Array.new
		XmiHelper.tagged_values(@xml).each do |uml_tagged_value|
			tagged_value = TaggedValue.new(uml_tagged_value, self)
			@tagged_values << tagged_value
		end		
	end

	# @return [Clazz]
	def participant
		return nil if @participant_id.nil? or @participant_id.empty?
		participant = @xmi_model.class_by_id(@participant_id)		
		return participant
	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			@name == obj
		elsif AssociationEnd == obj.class
    		@name == obj.name && participant.full_name == obj.participant.full_name
    	else
    		return false
    	end
	end	

	# @return [Stereotype]
	def stereotype_by_name(name)
		stereotype = @stereotypes.select{|obj| obj == name}
		return stereotype[0] if !stereotype.nil? && stereotype.size > 0
		nil		
	end

	# @return [TaggedValue]
	def tagged_value_by_name(tagged_value_name)
		tagged_value = @tagged_values.select{|obj| obj.name == tagged_value_name}
		return tagged_value[0] if !tagged_value.nil? && tagged_value.size > 0
		nil
	end

	# @return [String]
	def full_name
		"#{@parent_tag.full_name}::#{@name}"
	end

	# @return [String]
	def to_s
		if participant.nil?
			return "AssociationEnd[#{name}]"
		else
			return "AssociationEnd[#{name} (#{participant.full_name}])" 
		end
	end		
end