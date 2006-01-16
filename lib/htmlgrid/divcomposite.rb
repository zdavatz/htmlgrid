#!/usr/bin/env ruby
# DivComposite -- HtmlGrid -- 19.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/composite'

module HtmlGrid
	class DivComposite < AbstractComposite
		DIV_CLASS = nil
		DIV_ID = nil
		LEGACY_INTERFACE = false
		def init
			super
			@grid = []
			@css_grid = []
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
					css = nil
					if(klass = css_map[ypos])
						css = { 'class' => klass }
					end
					@css_grid.push(css)
				end
				div.push(label(create(component, @model, @session), component))
			}
		end
		def div_attributes(idx=nil)
			attr = {}
			if(klass = self.class.const_get(:DIV_CLASS))
				attr.store('class', klass)
			end
			if(idx && (css = @css_grid.at(idx)))
				attr.update(css)
			end
			if(klass = self.class.const_get(:DIV_ID))
				attr.store('id', klass)
			end
			attr
		end
		def label(component, key)
			if(labels? && (!component.respond_to?(:label?) || component.label?))
				label = SimpleLabel.new(key, component, @session, self)
				[label, component]
			else
				component
			end
		end
		def submit(model=@model, name=event())
			Submit.new(name, model, @session, self)
		end
		def to_html(context)
			res = ''
			@grid.each_with_index { |div, idx|
				res << context.div(div_attributes(idx)) { 
					div.flatten.collect { |item| 
						if(item.respond_to?(:to_html))
							item.to_html(context)
						else
							item
						end
					}
				}
			}
			res
		end
	end
end
