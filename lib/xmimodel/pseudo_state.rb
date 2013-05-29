require 'xmimodel/state'

class PseudoState < State

	attr_reader :kind

	def initialize(xml, activity_graph)
		super(xml, activity_graph)

		@kind = xml.attribute("kind").to_s				
	end

	def to_s
		"PseudoState"
	end	
end