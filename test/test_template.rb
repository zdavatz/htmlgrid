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
#	htmlgrid@ywesee.com, downloads.ywesee.com/ruby/htmlgrid
#
# TestTemplate -- htmlgrid -- 19.11.2002 -- hwyss@ywesee.com 

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
$LOAD_PATH << File.dirname(__FILE__)

require 'minitest'
require 'minitest/autorun'
require 'stub/cgi'
require 'sbsm/lookandfeel'
require 'htmlgrid/template'

class StubTemplateSession
	def flavor
		"gcc"
	end
	def language
		"de"
	end
  def http_protocol
    'http'
  end
  def server_name
    "testserver.com"
  end
	alias :default_language :language
end
class StubTemplateLookandfeel < SBSM::Lookandfeel
	RESOURCES = {
		:css	=>	"test.css"
	}
	DICTIONARIES = {
		"de"	=>	{
			:html_title	=>	"Test",
		}
	}
	def lookandfeel
		self
	end
end
class Template < HtmlGrid::Template
	META_TAGS = [
		{
			"http-equiv"	=>	"robots",
			"content"			=>	"follow, index",
		},
	]
	COMPONENTS = {
		[0,0]	=>	:foo,	
	}
	LEGACY_INTERFACE = false
	def foo(model)
		'foo'
	end
end

class TestTemplate < Minitest::Test
	def setup
		lookandfeel = StubTemplateLookandfeel.new(StubTemplateSession.new)
		@template = Template.new(nil, lookandfeel, nil)
	end
	def test_to_html
		result = ""
    result << @template.to_html(CGI.new)
    expected = [
      '<TITLE>Test</TITLE>',
      "<LINK rel=\"stylesheet\" type=\"text/css\" href=\"http://testserver.com/resources/gcc/test.css\">",
      '<META http-equiv="robots" content="follow, index">',
    ]
    expected.each_with_index { |line, idx|
      assert(result.index(line), "#{idx} Missing: #{line} in #{result}")
    }
	end
end
