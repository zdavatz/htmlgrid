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

require 'test/unit'
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

class TestForm < Test::Unit::TestCase
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
		expected = '<FORM ACCEPT-CHARSET="ISO-8859-1" NAME="stdform" METHOD="POST" ENCTYPE="multipart/form-data" ACTION="http://test.oddb.org/de/gcc">'
		assert_equal(0, result.index(expected), "expected\n#{result}\nto start with\n#{expected}")
	end
	def test_to_html
		result = @form.to_html(CGI.new)
		expected = [
			'<INPUT NAME="flavor" TYPE="hidden" VALUE="gcc">',
			'<INPUT NAME="language" TYPE="hidden" VALUE="de">',
			'<INPUT NAME="event" TYPE="hidden" ID="event" VALUE="foo">',
			'<INPUT NAME="state_id" TYPE="hidden" VALUE="1">',
		]
		expected.each { |line|
			assert(result.index(line), "\nmissing #{line}\n     in #{result}")
		}
	end
	def test_submit
		expected = '<INPUT name="foo" type="submit" value="Submit-Value">'
		assert_equal(expected, @form.submit(@model, @lookandfeel).to_html(CGI.new))
	end
	def test_onsubmit
		@form.onsubmit = 'submitted'
		expected = 'onSubmit="submitted"'	
		result = /<FORM[^>]+>/.match(@form.to_html(CGI.new))[0]
		assert(result.index(expected), "missing:\n#{expected}\nin:\n#{result}")
	end
	def test_onsubmit_init
		form = nil
		assert_nothing_raised { form = StubForm2.new(@model, @lookandfeel) }
		expected = 'onSubmit="submitted"'	
		result = /<FORM[^>]+>/.match(form.to_html(CGI.new))[0]
		assert(result.index(expected), "missing:\n#{expected}\nin:\n#{result}")
	end
end
