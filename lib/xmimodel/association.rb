# encoding: utf-8

require 'xmimodel/association_end'
require 'xmimodel/tag'

class Association < Tag

	attr_reader :name

	attr_reader :end_a
	attr_reader :end_b	
	
	def initialize(xml, parent)
		super(xml, parent)

		@name = xml.attribute("name").to_s.strip

		association_end = xml.xpath('./UML:Association.connection/UML:AssociationEnd')

		@end_a = AssociationEnd.new(association_end, 0, self)
		@end_b = AssociationEnd.new(association_end, 1, self)
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
		"Association[#{@name}]"
	end	
	
end