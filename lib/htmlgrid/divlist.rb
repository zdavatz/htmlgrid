#!/usr/bin/env ruby
# HtmlGrid::DivList -- davaz.com -- 20.09.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'

module HtmlGrid
	class DivList < HtmlGrid::DivComposite
		def compose
			@model.each { |item|
				super(item)
			} 
=begin
			if(header = self.class.const_get(:HEADER))
				@grid.push(create(header, @model, @session))
				@css_grid.push(nil)
			end
			if(footer = self.class.const_get(:FOOTER))
				@grid.push(create(footer, @model, @session))
				@css_grid.push(nil)
			end
=end
		end
	end
end
