#!/usr/bin/env ruby
# DivComposite -- HtmlGrid -- 19.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/composite'

module HtmlGrid
	class DivComposite < AbstractComposite
		DIV_CLASS = nil
		DIV_ID = nil
		def init
			super
			@grid = []
			compose()
		end
		def compose
			ypos = -1
			xpos = 0
			div = nil
			components.sort_by { |matrix, component|
				[matrix.at(1), matrix.at(0), matrix[2..-1]]
			}.each { |matrix, component|
				if((mpos = matrix.at(1).to_i) > ypos)
					xpos = 0
					ypos = mpos
					div = []
					@grid.push(div)
				end
				div.push(label(create(component, @model, @session), component))
			}
		end
		def div_attributes
			attr = {}
			if(klass = self.class.const_get(:DIV_CLASS))
				attr.store('class', klass)
			end
			if(klass = self.class.const_get(:DIV_ID))
				attr.store('id', klass)
			end
			attr
		end
		def label(component, key)
			if(labels?)
				label = SimpleLabel.new(key, component, @session, self)
				[label, component]
			else
				component
			end
		end
		def to_html(context)
			@grid.collect { |div|
				context.div(div_attributes) { 
					div.flatten.collect { |item| 
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
