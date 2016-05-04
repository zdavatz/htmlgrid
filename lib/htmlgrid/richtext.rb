#!/usr/bin/env ruby
# encoding: utf-8
# Richtext -- htmlgrid -- 29.06.2004 -- mhuggler@ywesee.com

require 'htmlgrid/component'

module HtmlGrid
	class RichText < Component
		def init
			super
			@elements = []
		end
		def <<(element)
			@elements.push(element)
		end
		def to_html(context)
			@elements.collect { |element|
				if(element.respond_to?(:to_html))
					element.to_html(context).force_encoding('utf-8')
				else
					element.to_s
				end
			}.join(' ')
		end
	end
end
