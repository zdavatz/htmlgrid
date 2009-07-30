#!/usr/bin/env ruby
# encoding: utf-8
# DivTemplate -- htmlgrid -- 04.05.2005 -- hwyss@ywesee.com

require 'htmlgrid/divcomposite'
require 'htmlgrid/template'

module HtmlGrid
	class DivTemplate < DivComposite
		include TemplateMethods
	end
end
