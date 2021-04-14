#!/usr/bin/env ruby
# encoding: utf-8
# HtmlGrid::DivList -- davaz.com -- 20.09.2005 -- mhuggler@ywesee.com

require 'htmlgrid/divcomposite'

module HtmlGrid
	class DivList < HtmlGrid::DivComposite
		def compose
			@model.each_with_index { |item, idx|
        @list_index = idx
				super(item)
			} if @model
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
