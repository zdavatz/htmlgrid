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
		def error_message
			if(@session.warning?)
				@session.warnings.each { |warning|
					message(warning, 'warning')
				}
			end
			if(@session.error?)
				@session.errors.each { |error|
					message(error, 'processingerror')
				}
			end
		end
		def message(obj, css_class)
			txt = HtmlGrid::Text.new(obj.message, @model, @session, self)
			if(txt.value.nil?)
				txt.value = @lookandfeel.lookup(obj.message, escape(obj.value))
			end
			unless(txt.value.nil?)
				@grid.insert_row(0, txt)
				@grid.set_colspan(0,0)
				@grid.add_style(css_class, 0, 0)
			end
		end
	end
end
