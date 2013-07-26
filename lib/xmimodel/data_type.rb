# encoding: utf-8

require 'xmimodel/tag'

class DataType < Tag

	attr_reader :name	
	
	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@name = xml.attribute("name").to_s.strip		
	end

	def to_s
		"DataType[#{@name}]"
	end	
end