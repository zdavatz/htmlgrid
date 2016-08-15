#!/usr/bin/env ruby
# encoding: utf-8
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
# Template -- htmlgrid -- 03.04.2012 -- yasaka@ywesee.com
# Template -- htmlgrid -- 23.02.2012 -- mhatakeyama@ywesee.com 
# Template -- htmlgrid -- 23.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/grid'
require 'htmlgrid/component'
require 'htmlgrid/value'
require 'htmlgrid/inputtext'
require 'htmlgrid/label'
require 'htmlgrid/text'

if RUBY_VERSION < '1.9'
  class Hash
    alias :key :index
  end
end

module HtmlGrid
	class AbstractComposite < Component
		LABELS = false
		LEGACY_INTERFACE = true
		SYMBOL_MAP = {}
		CSS_MAP = {}
		CSS_ID_MAP = {}
		CSS_STYLE_MAP = {}
		CSS_CLASS = nil
		CSS_ID = nil
		DEFAULT_CLASS = Value
		LOOKANDFEEL_MAP = {}

    def self.component(klass, key, name=nil)
      methname = klass.to_s.downcase.gsub('::', '_') << '_' << key.to_s
      define_method(methname) { |*args|
        model, session = args
        args = [model.send(key), session || @session, self]
        if(name)
          args.unshift(name)
          lookandfeel_map.store(methname.to_sym, name.to_sym)
        end
        klass.new(*args)
      }
      methname.to_sym
    end

		def init
			super
			setup_grid()
			compose()
		end
		def create(component, model=@model)
			if(component.is_a? Class)
				component.new(model, @session, self)
			elsif(component.is_a? Symbol)
				if(self.respond_to?(component, true))
					args = [model]
					if(self::class::LEGACY_INTERFACE)
						args.push(@session)
					end
					self.send(component, *args)
				elsif(klass = symbol_map[component])
					klass.new(component, model, @session, self)
				else
					self::class::DEFAULT_CLASS.new(component, model, @session, self)
				end
			elsif(component.is_a? String)
				val = @lookandfeel.lookup(component) { component.to_s }
        val.gsub(@@nl2br_ptrn, '<br>')
			end
		rescue StandardError => exc
			exc.backtrace.push(sprintf("%s::COMPONENTS[%s] in create(%s)", 
				self.class, components.key(component).inspect, component))
			raise exc
		end
		private
		def components
			@components ||= self::class::COMPONENTS.dup
		end
		def css_id_map
			@css_id_map ||= self::class::CSS_ID_MAP.dup
		end
		def css_map
			@css_map ||= self::class::CSS_MAP.dup
		end
		def css_style_map
			@css_style_map ||= self::class::CSS_STYLE_MAP.dup
		end
		def labels?
			self::class::LABELS
		end
		def lookandfeel_map 
			@lookandfeel_map ||= self::class::LOOKANDFEEL_MAP.dup
		end
		def symbol_map
			@symbol_map ||= self::class::SYMBOL_MAP.dup
		end
	end
	class TagComposite < AbstractComposite
		def compose(model=@model)
			components.sort { |a, b|
				a <=> b
			}.each { |pos, component|
				@grid.push(label(create(component, model), component))
				css = {}
				if(klass = css_map[pos])
					css.store('class', klass)
				end
				if(id = css_id_map[pos])
					css.store('id', id)
				end
				if(style = css_style_map[pos])
					css.store('style', style)
				end
				@css_grid.push(css.empty? ? nil : css)
			}
		end
		def create(component, model=@model)
			if(component.is_a? Class)
				component.new(model, @session, self)
			elsif(component.is_a? Symbol)
				if(self.respond_to?(component, true))
					self.send(component, model)
				elsif(klass = symbol_map[component])
					klass.new(component, model, @session, self)
				else
					self::class::DEFAULT_CLASS.new(component, model, @session, self)
				end
			elsif(component.is_a? String)
				val = @lookandfeel.lookup(component) { component.to_s }
        val.gsub(@@nl2br_ptrn, '<br>')
			end
		rescue StandardError => exc
			exc.backtrace.push(sprintf("%s::COMPONENTS[%s] in create(%s)", 
				self.class, components.index(component).inspect, component))
			raise exc
		end
		def insert_row(ypos, txt, css_class=nil)
			@grid[ypos, 0] = [[txt]]
			@css_grid[ypos, 0] = [css_class ? {'class' => css_class} : nil]
		end
		def label(component, key)
			if(labels? \
         && (!component.respond_to?(:label?) || component.label?))
				label = SimpleLabel.new(key, component, @session, self)
				[label, component]
			else
				component
			end
		end
		def setup_grid
			@grid = []
			@css_grid = []
		end
		def submit(model=@model, name=event())
			Submit.new(name, model, @session, self)
		end
		def tag_attributes(idx=nil)
			attr = {}
			if(klass = self.class.const_get(:CSS_CLASS))
				attr.store('class', klass)
			end
			if(id = self.class.const_get(:CSS_ID))
				attr.store('id', id)
			end
			if(idx && (css = @css_grid.at(idx)))
				attr.update(css)
			end
			attr
		end
	end
	class Composite < AbstractComposite
		COLSPAN_MAP = {}
		COMPONENT_CSS_MAP = {}
		CSS_MAP = {}
		DEFAULT_CLASS = InputText
		VERTICAL = false
		def compose(model=@model, offset=[0,0], bg_flag=false)
			comps = components
			css = css_map
      cids = css_id_map
			ccss = component_css_map
			colsp = colspan_map
			suffix = resolve_suffix(model, bg_flag)
			comps.keys.concat(css.keys).concat(colsp.keys).uniq.sort_by { |key| 
        [key.size, key] 
      }.each { |key|
				nkey = key[0,2]
				matrix = resolve_offset(key, offset)
				nmatrix = resolve_offset(nkey, offset)
				comp = compose_component(model, comps[key], matrix)
				if(style = css[key])
					@grid.add_style(style + suffix, *matrix)
				elsif(style = css[nkey])
					@grid.add_style(style + suffix, *nmatrix)
				end
        if(id = cids[key] || cids[nkey])
          comp.css_id = id
        end
				if(span = colsp[key])
					@grid.set_colspan(matrix.at(0), matrix.at(1), span)	
				end
			}
      # component-styles depend on components having been initialized 
      # -> separate iteration
      ccss.each { |key, cstyle|
        matrix = resolve_offset(key, offset)
        @grid.add_component_style(cstyle + suffix, *matrix)
      }
=begin
			compose_components(model, offset)
			compose_css(offset)
			compose_colspan(offset)
=end
		end
		alias :_compose :compose
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
			@grid.explode!
			super
		end
=end
		def full_colspan
			raw_span = components.keys.collect{ |key|
				key.at(0)
			}.max.to_i
			(raw_span > 0) ? raw_span + 1 : nil
		end
		def insert_row(ypos, txt, css_class=nil)
			@grid.insert_row(ypos, txt)
			@grid.set_colspan(0,ypos)
			@grid.add_style(css_class, 0, ypos) if(css_class)
		end
		def to_html(context)
			@grid.set_attributes(@attributes)
      super << @grid.to_html(context).force_encoding('utf-8')
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
		def compose_component(model, component, matrix)
			if(component)
				comp = create(component, model)
				if((tab = matrix.at(3)) && comp.respond_to?(:tabindex=))
					comp.tabindex = tab
				end
				@grid.add(label(comp, component), matrix.at(0), matrix.at(1), 
					self::class::VERTICAL)
        comp
			end
		end
		## compose_components: legacy-code
		def compose_components(model=@model, offset=[0,0])
			warn "HtmlGrid::List#compose_components is deprecated"
			each_component { |matrix, component|
				res = resolve_offset(matrix, offset)
				comp = create(component, model)
				if((tab = matrix.at(3)) && comp.respond_to?(:tabindex=))
					comp.tabindex = tab
				end
				@grid.add(label(comp, component), res.at(0), res.at(1), 
					self::class::VERTICAL)
			}
		end
		## compose_css: legacy-code
		def compose_css(offset=[0,0], suffix='')
			warn "HtmlGrid::List#compose_css is deprecated"
			each_css { |matrix, style| 
				@grid.add_style(style + suffix, *resolve_offset(matrix, offset))
			}
			each_component_css { |matrix, style|
				@grid.add_component_style(style + suffix, *resolve_offset(matrix, offset))
			}
		end
		def each_component(&block)
			(@sorted_components ||= components.sort).each(&block)
		end
		def each_component_css(&block)
			(@sorted_component_css_map ||= component_css_map.sort).each(&block)
		end
		def each_css(&block)
			(@sorted_css_map ||= css_map.sort).each(&block)
		end
		def label(component, key=nil)
			if labels?
				HtmlGrid::Label.new(component, @session, lookandfeel_key(key))
			else
				component
			end
		end
		def lookandfeel_key(component)
			lookandfeel_map.fetch(component) {
				component
			}
		end
		def setup_grid
			@grid = Grid.new
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
		def resolve_suffix(model, bg_flag=false)
			bg_flag ? self::class::BACKGROUND_SUFFIX : ''
		end
	end
end
