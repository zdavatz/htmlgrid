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
# Template -- htmlgrid -- 23.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'

module HtmlGrid
	class SpanComposite < TagComposite
		def to_html(context)
			res = ''
			@grid.each_with_index { |span, idx| 
				res << context.span(tag_attributes(idx)) {
					if(span.respond_to?(:to_html))
						span.to_html(context).force_encoding('utf-8')
					else
						span	
					end
				}	
			}
			res
		end
	end
end
