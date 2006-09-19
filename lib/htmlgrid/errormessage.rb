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
# ErrorMessage -- htmlgrid -- 10.04.2003 -- benfay@ywesee.com

module HtmlGrid
	module ErrorMessage
		private
		def error_message(ypos = 0)
			@displayed_messages = []
			if(@session.warning?)
				messages(@session.warnings, 'warning', ypos)
			end
			if(@session.error?)
				messages(@session.errors, 'processingerror', ypos)
			end
		end
		def error_text(obj)
			message = obj.message
			txt = HtmlGrid::Text.new(message, @model, @session, self)
			if(txt.value.nil?)
				txt.value = @lookandfeel.lookup(message, escape(obj.value))
			end
			if(txt.value.nil? && (match = /^(._[^_]+)_(.*)$/.match(message.to_s)) \
				&& (label = @lookandfeel.lookup(match[2])))
				txt.value = @lookandfeel.lookup(match[1], label)
			end
			txt
		end
		def message(obj, css_class, ypos=0)
			@displayed_messages ||= []
			message = obj.message
			unless(@displayed_messages.include?(message))
				@displayed_messages.push(message)
				txt = error_text(obj)
				unless(txt.value.nil?)
					insert_row(ypos, txt, css_class)
				end
			end
		end
		def messages(ary, css_class, ypos=0)
			ary.sort_by { |item|
				(components.index(item.key) || [-1,-1]).reverse
			}.reverse.each { |item|
				message(item, css_class, ypos)
			}
		end
	end
end
