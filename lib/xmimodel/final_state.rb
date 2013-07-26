# encoding: utf-8

require 'xmimodel/state'

class FinalState < State

	def initialize(xml, parent_tag)
		super(xml, parent_tag)
	end

	def to_s
		"FinalState"
	end	

end