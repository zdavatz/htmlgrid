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
# TestInput -- htmlgrid -- 18.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path("../lib", File.dirname(__FILE__))

require 'test/unit'
require 'stub/cgi'
require 'htmlgrid/button'
require 'htmlgrid/inputcurrency'

class StubInputLookandfeel
	def attributes(key)
		{
			"bar"	=>	"roz",
		}
	end
	def lookup(key)
		'Foo'
	end
	def lookandfeel
		self
	end
	def format_price(price)
		sprintf('%.2f', price.to_f/100.0) if price.to_i > 0
	end
end
class StubInputModel
	def foo
		1234
	end
end

class TestInput < Test::Unit::TestCase
	def test_input
		input = HtmlGrid::Input.new(:foo, nil, StubInputLookandfeel.new)
		assert_equal('<INPUT bar="roz" name="foo" value="">', input.to_html(CGI.new))
	end
	def test_button
		input = HtmlGrid::Button.new(:foo, nil, StubInputLookandfeel.new)
		assert_equal('<INPUT bar="roz" value="Foo" type="button" name="foo">', input.to_html(CGI.new))
	end
end
class TestInputCurrency < Test::Unit::TestCase
	def test_to_html
		input = HtmlGrid::InputCurrency.new(:foo, StubInputModel.new, StubInputLookandfeel.new)
		assert_equal('<INPUT bar="roz" name="foo" value="12.34" type="text">', input.to_html(CGI.new))
	end
end
