# encoding: utf-8

require 'xmimodel/state'
require 'xmimodel/tag'

class PseudoState < State

	attr_reader :kind

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@kind = xml.attribute("kind").to_s				
	end

	def to_s
		"PseudoState[#{name}]"
	end	
end