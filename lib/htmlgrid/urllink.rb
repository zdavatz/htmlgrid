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
# UrlLink -- htmlgrid -- 10.06.2003 -- aschrafl@ywesee.com

require 'htmlgrid/link'

module HtmlGrid 
	class UrlLink < Link
		def init
			super
			if(@model.respond_to?(@name))
				@value = @model.send(@name).to_s 
			end
			compose_link
		end
	end
	class HttpLink < UrlLink
    @@http_ptrn = /^http:/
		LABEL = true
		def compose_link
			unless @value.nil?
				if @@http_ptrn.match(@value)
					self.href = @value  
				else
					self.href = "http://" + @value
				end
				set_attribute('target', '_blank')
			end
		end
	end
	class MailLink < UrlLink
		LABEL = true
    @@mailto_ptrn = /^mailto:/
		def compose_link
			unless @value.empty?
				self.href = @value  
				unless @@mailto_ptrn.match(@value)
					self.href = "mailto:"+@value
				end
			end
		end
	end
end
