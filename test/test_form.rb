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
# TestForm -- htmlgrid -- 25.11.2002 -- hwyss@ywesee.com 

$: << File.dirname(__FILE__)
$: << File.expand_path("../lib", File.dirname(__FILE__))

require 'minitest/autorun'
require 'htmlgrid/form'
require 'stub/cgi'

class StubFormModel; end
class StubFormLookandfeel
	def attributes(key)
		{}
	end
	def base_url
		'http://test.oddb.org/de/gcc'
	end
	def flavor
		'gcc'
	end
	def language
		'de'
	end
	def lookup(key)
		'Submit-Value'
	end
	def lookandfeel
		self
	end
	def state
		0
	end
end
class StubFormComponent < HtmlGrid::Component
	def init
		self.onsubmit = 'submitted'
	end
end
class Form < HtmlGrid::Form
	EVENT = :foo
	COMPONENTS = {}
	public :submit
end
class StubForm2 < HtmlGrid::Form
	EVENT = :foo
	COMPONENTS = {
		[0,0] => StubFormComponent,
	}
end
class StubFormMultiPart < HtmlGrid::Form
	EVENT = :foo
	COMPONENTS = {}
	TAG_METHOD = :multipart_form
end

class TestForm < Minitest::Test
	def setup
		@model = StubFormModel.new
		@lookandfeel = StubFormLookandfeel.new
		@form = Form.new(@model, @lookandfeel)
	end
	def test_event
		assert_equal(:foo, @form.event)
	end
	def test_multipart
		form = StubFormMultiPart.new(@model, @lookandfeel)
		result = form.to_html(CGI.new)
    expected = '<FORM NAME="stdform" METHOD="POST" ACTION="http://test.oddb.org/de/gcc" ACCEPT-CHARSET="UTF-8" ENCTYPE="multipart/form-data">'
    assert_equal(0, result.index(expected), "expected\n#{result}\nto start with\n#{expected}")
	end
	def test_to_html
		result = @form.to_html(CGI.new)
    expected = [
      '<INPUT TYPE="hidden" NAME="flavor" VALUE="gcc">',
      '<INPUT TYPE="hidden" NAME="language" VALUE="de">',
      '<INPUT NAME="event" ID="event" VALUE="foo" TYPE="hidden">',
      '<INPUT TYPE="hidden" NAME="state_id" VALUE="1">',
    ]
		expected.each_with_index { |line, idx|
			assert(result.index(line), "#{idx}: missing #{line}\n     in #{result}")
		}
	end
	def test_submit
    html = @form.submit(@model, @lookandfeel).to_html(CGI.new)
    expected = '<INPUT value="Submit-Value" type="submit" name="foo">'
		assert_equal(expected, html)
	end
	def test_onsubmit
		@form.onsubmit = 'submitted'
		expected = 'onSubmit="submitted"'	
		result = /<FORM[^>]+>/.match(@form.to_html(CGI.new))[0]
		assert(result.index(expected), "missing:\n#{expected}\nin:\n#{result}")
	end
	def test_onsubmit_init
		form = nil
		form = StubForm2.new(@model, @lookandfeel)
		expected = 'onSubmit="submitted"'	
		result = /<FORM[^>]+>/.match(form.to_html(CGI.new))[0]
		assert(result.index(expected), "missing:\n#{expected}\nin:\n#{result}")
	end
end
