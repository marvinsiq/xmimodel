# encoding: utf-8

require 'xmimodel/tag'

class CallEvent < Tag

	attr_reader :name
	attr_accessor :operation
	attr_reader :operation_id

	def initialize(xml, parent)
		super(xml, parent)

		@namespace = parent

		@name = xml.attribute("name").to_s
		@operation_id = xml.attribute("operation").to_s		
	end

end