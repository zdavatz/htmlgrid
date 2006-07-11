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
# Select -- htmlgrid -- 10.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/namedcomponent'

module HtmlGrid
	class AbstractSelect < NamedComponent
		LABEL = true
		attr_accessor :selected, :valid_values
		def to_html(context)
			context.select(@attributes) {
				selection(context)
			}
		end
	end
	class Select < AbstractSelect
		def data_origin
			if(@model.respond_to?(:data_origin))
				@model.data_origin(@name)
			end
		end
		private
		def selection(context)
			@selected ||= (@model.send(@name).to_s if(@model.respond_to?(@name)))
			@valid_values ||= @session.valid_values(@name)
			@valid_values.collect { |value|
				val = value.to_s
				attributes = { "value" => val }
				attributes.store("selected", true) if(val == selected)
				context.option(attributes) { @lookandfeel.lookup(value) }
			}
		end
	end
	class DynSelect < AbstractSelect
		private
		def selection(context)
			@model.selection.collect { |value|
				val = value.name.to_s
				attributes = { "value" => value.sid }
				attributes.store("selected", true) if(value == @model.selected)
				context.option(attributes) { value.name }
			}
		end
	end
end
