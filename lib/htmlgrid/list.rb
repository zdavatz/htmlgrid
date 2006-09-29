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
# List -- htmlgrid -- 03.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'htmlgrid/value'

module HtmlGrid
	class List < Composite
    BACKGROUND_ROW = nil
		BACKGROUND_SUFFIX = '-bg'
		CSS_HEAD_MAP = {}
		DEFAULT_CLASS = Value
		DEFAULT_HEAD_CLASS = nil
		EMPTY_LIST = false 
		EMPTY_LIST_KEY = :empty_list
		OFFSET_STEP = [0,1]
		OMIT_HEADER = false
		OMIT_HEAD_TAG = false
		SORT_DEFAULT = :to_s
		SORT_HEADER = true
		SORT_REVERSE = false
		STRIPED_BG = true
		def compose(model=@model, offset=[0,0])
			unless (self::class::OMIT_HEADER)
				offset = compose_header(offset) 
			end
			offset = if(model.empty?)
				compose_empty_list(offset) unless (self::class::EMPTY_LIST)
			else
				compose_list(model, offset)
			end
			compose_footer(offset)
		end
		def compose_footer(offset=[0,0])
		end
		def compose_empty_list(offset)
			@grid.add(@lookandfeel.lookup(self::class::EMPTY_LIST_KEY), 
				*offset)
			@grid.add_attribute('class', 'list', *offset)
			#@grid[*offset].add_style('list')
			@grid.set_colspan(*offset)
			resolve_offset(offset, self::class::OFFSET_STEP)
		end
		def compose_list(model=@model, offset=[0,0])
			bg_flag = false
			model.each_with_index { |mdl, idx|
				@list_index = idx
				_compose(mdl, offset, bg_flag)
				#compose_components(mdl, offset)
				#compose_css(offset, resolve_suffix(mdl, bg_flag))
				#compose_colspan(offset)
				if(rcss = row_css(mdl, bg_flag))
					@grid.set_row_attributes({'class' => rcss}, offset.at(1),
                                  self::class::OFFSET_STEP.at(1))
				end
				offset = resolve_offset(offset, self::class::OFFSET_STEP)
				bg_flag = !bg_flag if self::class::STRIPED_BG
			}
			offset
		end	
		def compose_header(offset=[0,0])
			step = if(defined?(self::class::HEAD_OFFSET_STEP))
				self::class::HEAD_OFFSET_STEP
			else
				self::class::OFFSET_STEP
			end
			ystep = step.at(1)
			components.each { |matrix, component|
				key = lookandfeel_key(component)
				header_key = 'th_' << key.to_s
				if(txt = @lookandfeel.lookup(header_key))
					if(self::class::SORT_HEADER)
						@grid.add(sort_link(header_key, matrix, component), *matrix)
					else
						@grid.add(txt, *matrix)
					end
				end
				if((cls = css_head_map[matrix]) \
					|| (cls = self::class::DEFAULT_HEAD_CLASS))
					@grid.add_attribute('class', cls, *matrix)
					#link.attributes['class'] = cls
				end
				unless(self::class::OMIT_HEAD_TAG || matrix.at(1) >= ystep)
					@grid.add_tag('TH', *matrix) 
				end
				if(title = @lookandfeel.lookup(header_key + '_title'))
					@grid.add_attribute('title', title, *matrix)
				end
			}
			#span = full_colspan || 1
			resolve_offset(offset, step)
		end
		def css_head_map
			@css_head_map ||= self::class::CSS_HEAD_MAP.dup
		end
		private
		def init
			@model ||= []
			@index = 0
			sort_model()
			if(self::class::SORT_REVERSE && (@session.event != :sort))
				@model = @model.reverse 
			end
			super
		end
    def row_css(model, bg_flag)
      self::class::BACKGROUND_ROW if(bg_flag)
    end
    def sort_link(header_key, matrix, component)
      link = Link.new(header_key, @model, @session, self)
      args = {
        'sortvalue'	=>	component.to_s,
      }
      link.attributes['href'] = @lookandfeel.event_url(:sort, args)
      if((cls = css_head_map[matrix]) \
        || (cls = self::class::DEFAULT_HEAD_CLASS))
        link.attributes['class'] = cls
      end
      link
    end
		def sort_model
			if(self::class::SORT_DEFAULT && (@session.event != :sort))
				begin
					block = self::class::SORT_DEFAULT
					unless(block.is_a?(Proc))
						block = Proc.new { |item| 
							begin
								item.send(self::class::SORT_DEFAULT) 
							rescue RuntimeError => e
								item.to_s
							end
						} 
					end
					@model = @model.sort_by(&block)
				rescue StandardError => e
					puts "could not sort: #{e.message}"
				end
			end
		end
	end
end
