# encoding: utf-8

##
# UML:Generalization
class Generalization

	attr_reader :xml
	
	attr_reader :id
	attr_reader :child
	attr_reader :parent

	def initialize(xml, xmi_model)
		@xml = xml
		@xmi_model = xmi_model

		@id = xml.attribute("xmi.id").to_s
		@child = XmiHelper.generalization_child(xml)
		@parent = XmiHelper.generalization_parent(xml)
	end

	def child_obj
		return nil if @child.nil? or @child.empty?
		@child_obj = @xmi_model.class_by_id(@child)
	end

	def parent_obj
		return nil if @parent.nil? or @parent.empty?
		@parent_obj = @xmi_model.class_by_id(@parent)
	end

	def to_s
		"Generalization[#{@parent_obj} <- #{@child_obj}]"
	end

end