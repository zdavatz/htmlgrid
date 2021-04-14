#!/usr/bin/env ruby
# encoding: utf-8
# DivComposite -- HtmlGrid -- 19.04.2005 -- hwyss@ywesee.com

require 'htmlgrid/composite'

module HtmlGrid
	class DivComposite < TagComposite
		def compose(model=@model)
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
					css = {}
					if(klass = css_map[ypos])
						css.store('class', klass)
					end
					if(id = css_id_map[ypos])
						css.store('id', id)
					end
					if(style = css_style_map[ypos])
						css.store('style', style)
					end
					@css_grid.push(css.empty? ? nil : css)
				end
				div.push(label(create(component, model), component))
			}
		end
		def to_html(context)
			res = ''
			@grid.each_with_index { |div, idx|
        res << context.div(tag_attributes(idx)) {
          div.flatten.inject('') { |html, item|
            html << if(item.respond_to?(:to_html))
                      item.to_html(context).force_encoding('utf-8')
                    else
                      item.to_s
                    end
          }
        }
			} if @grid
			res
		end
	end
end
