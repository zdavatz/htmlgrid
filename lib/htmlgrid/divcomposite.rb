#!/usr/bin/env ruby
# DivComposite -- HtmlGrid -- 19.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/composite'

module HtmlGrid
	class DivComposite < AbstractComposite
		def init
			super
			@grid = []
			compose()
		end
		def compose
			ypos = -1
			xpos = 0
			div = nil
			components.sort.each { |matrix, component|
				if((mpos = matrix.at(1).to_i) > ypos)
					xpos = 0
					ypos = mpos
					div = []
					@grid.push(div)
				end
				div.push(create(component, @model, @session))
			}
		end
		def to_html(context)
			@grid.collect { |div|
				context.div { 
					div.collect { |item| 
						if(item.respond_to?(:to_html))
							item.to_html(context)
						else
							item
						end
					}
				}
			}.join()
		end
	end
end
