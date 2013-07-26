# encoding: utf-8

require 'xmimodel/tag'

##
# UML:Generalization
class Generalization < Tag

	attr_reader :child
	attr_reader :parent

	def initialize(xml, parent_tag)
		super(xml, parent_tag)

		@child = XmiHelper.generalization_child(xml)
		@parent = XmiHelper.generalization_parent(xml)
	end

	def child_obj
		return nil if @child.nil? or @child.empty?
		@child_obj = xml_root.class_by_id(@child)
	end

	def parent_obj
		return nil if @parent.nil? or @parent.empty?
		@parent_obj = xml_root.class_by_id(@parent)
	end

	def to_s
		"Generalization[#{@parent_obj} <- #{@child_obj}]"
	end

end