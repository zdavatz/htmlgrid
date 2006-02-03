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
# Input -- htmlgrid -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/namedcomponent'

module HtmlGrid
	class Input < NamedComponent
		def init
			super
			@attributes['name'] = @name.to_s
			value = nil
			if(@model.respond_to?(@name))
				value = @model.send(@name)
			end
			if(value.nil? \
				&& @session.respond_to?(:user_input))
				value = @session.user_input(@name)
			end
			if(value.nil? && autofill? \
				&& @session.respond_to?(:get_cookie_input))
				value = @session.get_cookie_input(@name)
			end
			if(value.is_a? RuntimeError)
				value = value.value 
			end
			self.value = value
		end
		def value=(value)
			@attributes.store("value", value.to_s)
			@value = value
		end
		def to_html(context)
			context.input(@attributes)
		end
	end
end
