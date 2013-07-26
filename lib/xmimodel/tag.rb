# encoding: utf-8

class Tag
	
	# @return [Nokogiri::XML::Element]
	attr_reader :xml

	# @return [Tag]
	attr_reader :parent_tag

	# @return [String]
	attr_reader :id

	##
	# Constructor. 
	# 
	# @param xml [Nokogiri::XML::Element]
	# @param parent_tag [Tag]
	def initialize(xml, parent_tag)

		raise "Diferente de Tag. #{parent_tag.class}" if !parent_tag.kind_of?(Tag) && parent_tag.class != XmiModel

		@xml = xml
		@parent_tag = parent_tag

		@id = xml.attribute("xmi.id").to_s
	end

	def xml_root
		parent_tag = @parent_tag
		until parent_tag.class == XmiModel
			parent_tag = parent_tag.parent_tag
		end
		parent_tag
	end
end