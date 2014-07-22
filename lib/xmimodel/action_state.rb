# encoding: utf-8

require 'xmimodel/state'
require 'xmimodel/tag'

class ActionState < State

	attr_reader :deferrable_event

	def initialize(xml, activity_graph)
		super(xml, activity_graph)
		@deferrable_event = xml.attribute("deferrableEvent").to_s
		true
	end

	def to_s
		"ActionState[#{name}]"
	end	

end