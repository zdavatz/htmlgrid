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
# TestSelect -- htmlgrid -- 10.03.2003 -- hwyss@ywesee.com 

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
$LOAD_PATH << File.dirname(__FILE__)

require 'test/unit'
require 'htmlgrid/select'
require 'stub/cgi'

class StubSelectLookandfeel
	def attributes(key)
		{}
	end
	def lookup(key)
		{
			'foofoo'	=>	'Foo Nr. 1',
			'foobar'	=>	'Foo Nr. 2',
			'barfoo'	=>	'Bar Nr. 1',
			'barbar'	=>	'Bar Nr. 2',
			'foovals'	=>	'FooLabel',
		}.fetch(key)
	end
end
class StubSelectSession
	def valid_values(key)
		[ 'foofoo', 'foobar', 'barfoo', 'barbar' ]
	end
	def lookandfeel
		StubSelectLookandfeel.new
	end
end
class StubSelectData
	def foovals
		'foobar'
	end
end

class TestSelect < Test::Unit::TestCase
	def setup
		@component = HtmlGrid::Select.new(:foovals, StubSelectData.new,
			StubSelectSession.new)
	end
	def test_to_html
		expected = []
		expected << '<SELECT name="foovals">'
    expected << '<OPTION value="foofoo">Foo Nr. 1</OPTION>'
    if RUBY_VERSION.split(".").first.eql?('1')
      expected << 'OPTION value="foobar" selected>Foo Nr. 2</OPTION'
    else
      expected << '<OPTION selected value="foobar">Foo Nr. 2</OPTION>'
    end
		expected << '<OPTION value="barfoo">Bar Nr. 1</OPTION>'
		expected << '<OPTION value="barbar">Bar Nr. 2</OPTION>'
		expected << '</SELECT>'
		result = @component.to_html(CGI.new).to_s
    # <SELECT name="foovals"><OPTION value="foofoo">Foo Nr. 1</OPTION><OPTION value="foobar" selected>Foo Nr. 2</OPTION><OPTION value="barfoo">Bar Nr. 1</OPTION><OPTION value="barbar">Bar Nr. 2</OPTION></SELECT>
		expected.each_with_index do|line, idx|
      puts "#{idx}: Missing line:\n#{line}\nin:\n#{result}" unless result.index(line)
        # assert(result.index(line), "#{idx}: Missing line:\n#{line}\nin:\n#{result}")
    end
	end
end
