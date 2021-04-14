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
# PopupLink -- htmlgrid -- 20.03.2003 -- hwyss@ywesee.com

require "htmlgrid/link"

module HtmlGrid
  class PopupLink < Link
    attr_writer :width, :height
    attr_writer :locationbar, :scrollbars, :resizable, :toolbar, :menubar
    def init
      super
      @scrollbars = true
      @resizable = true
      @toolbar = true
      @menubar = false
      @locationbar = false
      @width = 750
      @height = 460
    end
    @@name_ptrn = /[^a-z]+/i
    def to_html(context)
      props = {
        "scrollbars"	=>	yesorno(@scrollbars),
        "resizable"	=>	yesorno(@resizable),
        "toolbar"	=>	yesorno(@toolbar),
        "menubar"	=>	yesorno(@menubar),
        "locationbar"	=>	yesorno(@locationbar),
        "width"	=>	@width,
        "height"	=>	@height
      }.collect { |key, val|
        [key, val].join("=")
      }.join(",")
      name = @lookandfeel.lookup(@name).to_s.gsub(@@name_ptrn, "")
      script = "window.open('#{href}', '#{name}', '#{props}').focus(); return false"
      @attributes.store("onClick", script)
      super
    end

    private

    def yesorno(value)
      value ? "yes" : "no"
    end
  end
end
