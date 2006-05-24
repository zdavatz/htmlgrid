#!/usr/bin/env ruby
# HtmlGrid::SpanList -- davaz.com -- 04.05.2006 -- mhuggler@ywesee.com

require 'htmlgrid/spancomposite'

module HtmlGrid
	class SpanList < HtmlGrid::SpanComposite
		def compose
			@model.each { |item| 
				super(item)
			}
		end
	end
end
