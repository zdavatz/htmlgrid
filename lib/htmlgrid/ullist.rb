#!/usr/bin/env ruby
# encoding: utf-8
# HtmlGrid::UlList -- davaz.com -- 25.04.2006 -- mhuggler@ywesee.com

require 'htmlgrid/ulcomposite'

module HtmlGrid
	class UlList < HtmlGrid::UlComposite
		def compose(model=@model)
			@model.each { |item|
				super(item)
			}
		end
	end
end
