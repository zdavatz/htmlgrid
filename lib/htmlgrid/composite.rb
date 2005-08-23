#!/usr/bin/env ruby
#
#	HtmlGrid -- HyperTextMarkupLanguage Framework
#	Copyright (C) 2003 ywesee - intellectual capital connected
# Andreas Schrafl, Benjamin Fay, Hannes Wyss, Markus Huggler
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#	ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zuerich, Switzerland
#	htmlgrid@ywesee.com, www.ywesee.com/htmlgrid
#
# Template -- htmlgrid -- 23.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/grid'
require 'htmlgrid/component'
require 'htmlgrid/value'
require 'htmlgrid/inputtext'
require 'htmlgrid/label'
require 'htmlgrid/text'

module HtmlGrid
	class AbstractComposite < Component
		LABELS = false
		LEGACY_INTERFACE = true
		SYMBOL_MAP = {}
		def create(component, model, session)
			if(component.is_a? Class)
				component.new(model, session, self)
			elsif(component.is_a? Symbol)
				if(self.respond_to?(component, true))
					args = [model]
					if(self::class::LEGACY_INTERFACE)
						args.push(session)
					end
					self.send(component, *args)
				elsif(klass = symbol_map[component])
					#puts "creating #{klass} for #{component}"
					klass.new(component, model, session, self)
				elsif(model.respond_to?(component))
					#puts "input for #{component}"
					#Value.new(component, model, session, self)
					self::class::DEFAULT_CLASS.new(component, model, session, self)
				else
					#p "nothing found for #{component}"
				end
			elsif(component.is_a? String)
				#Text.new(component.intern, model, session, self)
				@lookandfeel.lookup(component).to_s.gsub(/(\n)|(\r)|(\r\n)/, '<br>')
			end
		end
		private
		def components
			@components ||= self::class::COMPONENTS.dup
		end
		def labels?
			self::class::LABELS
		end
		def symbol_map
			@symbol_map ||= self::class::SYMBOL_MAP.dup
		end
	end
	class Composite < AbstractComposite
		COLSPAN_MAP = {}
		COMPONENT_CSS_MAP = {}
		CSS_MAP = {}
		DEFAULT_CLASS = InputText
		VERTICAL = false
		def compose(model=@model, offset=[0,0])
			compose_components(model, offset)
			compose_css(offset)
			compose_colspan(offset)
		end
		def compose_colspan(offset)
			colspan_map.each { |matrix, span|
				res = resolve_offset(matrix, offset)
				@grid.set_colspan(res.at(0), res.at(1), span)	
			}
		end
		def event
			@container.event if @container.respond_to?(:event)
		end
=begin
		def explode!
			super
			@grid.explode!
			@grid = nil
		end
=end
		def full_colspan
			raw_span = components.keys.collect{ |key|
				key.at(0)
			}.max.to_i
			(raw_span > 0) ? raw_span + 1 : nil
		end
		def to_html(context)
			@grid.set_attributes(@attributes)
			super << @grid.to_html(context)
		end
		private
		def back(model=@model, session=@session)
			bak = HtmlGrid::Button.new(:back, model, session, self)	
			url = @lookandfeel.event_url(:back)
			bak.set_attribute("onClick","document.location.href='#{url}';")
			bak
		end
		def colspan_map
			@colspan_map ||= self::class::COLSPAN_MAP.dup
		end
		def component_css_map
			@component_css_map ||= self::class::COMPONENT_CSS_MAP.dup
		end
		def compose_components(model=@model, offset=[0,0])
			components.sort.each { |matrix, component|
				res = resolve_offset(matrix, offset)
				comp = create(component, model, @session)
				if((tab = matrix.at(3)) && comp.respond_to?(:tabindex=))
					comp.tabindex = tab
				end
				@grid.add(label(comp, component), res.at(0), res.at(1), 
					self::class::VERTICAL)
			}
		end
		def compose_css(offset=[0,0], suffix='')
			css_map.sort.each { |matrix, style| 
				@grid.add_style(style + suffix, *resolve_offset(matrix, offset))
			}
			component_css_map.sort.each { |matrix, style|
				@grid.add_component_style(style + suffix, *resolve_offset(matrix, offset))
			}
		end
		def css_map
			@css_map ||= self::class::CSS_MAP.dup
		end
		def init
			super
			@grid = Grid.new
			compose()
		end
		def label(component, key=nil)
			if labels?
				HtmlGrid::Label.new(component, @session, key)
			else
				component
			end
		end
		def submit(model=@model, session=@session, name=event())
			Submit.new(name, model, session, self)
		end
		def resolve_offset(matrix, offset=[0,0])
			result = []
			matrix.each_with_index{ |value, index|
				result.push(value+offset.at(index).to_i)
			}
			result
		end
	end
end
