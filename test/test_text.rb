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
# TextText -- htmlgrid -- 20.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path("../lib", File.dirname(__FILE__))

require 'test/unit'
require 'htmlgrid/text'

class StubTextLookandfeel
	def lookup(key)
		{
			:foo	=>	"Foo Text!",
			:navigation_divider =>	"&nbsp;|&nbsp;",
		}[key]
	end
	def attributes(key)
		{"foo"	=>	"bar"} if key==:foo
	end
	def lookandfeel
		self
	end
end

class TestText < Test::Unit::TestCase
	def setup
		@view = HtmlGrid::Text.new(:foo, nil, StubTextLookandfeel.new)
	end
	def test_respond_to_attributes
		assert_respond_to(@view, :attributes)
	end
	def test_to_html
		assert_equal("Foo Text!", @view.to_html(nil))
	end
	def test_init
		expected = {
			"foo"		=>	"bar",
			"name"	=>	"foo",
		}
		assert_equal(expected, @view.attributes)
	end
end
