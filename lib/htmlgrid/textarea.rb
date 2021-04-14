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
# Textarea -- htmlgrid  -- 12.12.2002 -- benfay@ywesee.com

require "htmlgrid/input"

module HtmlGrid
  class Textarea < Input
    attr_writer :value
    attr_accessor :unescaped
    def to_html(context)
      context.textarea(@attributes) {
        _to_html(context, @value)
      }
    end

    def escape_value(elm)
      @unescaped ? elm.to_s : escape(elm.to_s)
    end

    def _to_html(context, value = @value)
      if value.is_a?(Array)
        value.collect { |elm| escape_value elm }.join("\n")
      else
        escape_value value
      end.strip
    end
  end
end
