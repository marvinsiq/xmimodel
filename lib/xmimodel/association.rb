# encoding: utf-8

require 'xmimodel/association_end'
require 'xmimodel/tag'

class Association < Tag

	attr_reader :name

	attr_reader :end_a
	attr_reader :end_b

	# @return [Array<Stereotype>] Association end stereotypes.
	attr_reader :stereotypes

	# @return [Array<TaggedValue>] Association end tagged values.
	attr_reader :tagged_values	
	
	def initialize(xml, parent)
		super(xml, parent)

		@name = xml.attribute("name").to_s.strip

		association_end = xml.xpath('./UML:Association.connection/UML:AssociationEnd')

		@end_a = AssociationEnd.new(association_end, 0, self)
		@end_b = AssociationEnd.new(association_end, 1, self)

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

	def stereotype_by_name(name)
		stereotype = @stereotypes.select{|s| s.name == name}
		return stereotype[0] if !stereotype.nil? && stereotype.size > 0
		nil		
	end

	def tagged_value_by_name(tagged_value_name)
		tagged_value = @tagged_values.select{|t| t.name == tagged_value_name}
		return tagged_value[0] if !tagged_value.nil? && tagged_value.size > 0
		nil			
	end	

	# @return [String]
	def full_name
		if @name.nil? or @name.empty?
			"#{@end_a.name}[#{@end_a.participant.full_name}] - #{@end_b.name}[#{@end_b.participant.full_name}]"
		else
			"#{@name}(#{@end_a.name}[#{@end_a.participant.full_name}] - #{@end_b.name}[#{@end_b.participant.full_name}])"
		end
	end	

	def to_s
		if @name.nil? or @name.empty?
			"Association[#{@end_a.participant.full_name} - #{@end_b.participant.full_name}]"
		else
			"Association[#{@end_a.participant.full_name} - #{@end_b.participant.full_name} (#{@name})]"
		end
	end	
	
end