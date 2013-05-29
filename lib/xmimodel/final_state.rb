require 'xmimodel/state'

class FinalState < State

	def initialize(xml, activity_graph)
		super(xml, activity_graph)
	end

	def to_s
		"FinalState"
	end	

end