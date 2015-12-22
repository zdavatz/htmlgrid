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
#TestFormList -- htmlgrid -- 25.03.2003 --aschrafl@ywesee.com 

$: << File.dirname(__FILE__)
$: << File.expand_path("../lib", File.dirname(__FILE__))

require 'test/unit'
require 'htmlgrid/formlist'
require 'stub/cgi'

class StubFormList < HtmlGrid::FormList
	attr_reader :model
	COMPONENTS = {
		[0,0]	=>	:jaguar,
		[1,0]	=>	:panther,
	}	
	CSS_MAP = {
		[0,0]	=>	'flecken',
		[1,0]	=>	'schwarz',
	}
	SORT_HEADER = false
	SORT_DEFAULT = :foo
end
class StubFormListLookandfeel
	def lookup(key)
		key.to_s
	end
	def attributes(key)
		{}
	end
	def base_url
		"http://www.ywesee.com"
	end
	def event_url(event)
		"http://www.ywesee.com/event"
	end
	def flavor
		"strawberry"
	end
	def language
		"de"
	end
end
class StubFormListSession
	attr_accessor :event
	def lookandfeel
		StubFormListLookandfeel.new
	end
	def state
		0
	end
end
class StubFormListModel
	attr_reader :foo
	def initialize(foo)
		@foo = foo
	end
	def jaguar
		'Jaguar'
	end
	def panther
		'Panther'
	end
end

class TestFormList < Test::Unit::TestCase
	def setup
		model = [
			StubFormListModel.new(3),
			StubFormListModel.new(2),
			StubFormListModel.new(4),
			StubFormListModel.new(1),
		]
		@list = StubFormList.new(model, StubFormListSession.new)
	end
	def test_to_html
		result = @list.to_html(CGI.new)
    expectations = [
      '<INPUT value="new_item" type="submit" name="new_item">',
      '<INPUT TYPE="hidden" NAME="flavor" VALUE="strawberry">',
      '<INPUT TYPE="hidden" NAME="language" VALUE="de">',
      '<INPUT NAME="event" ID="event" VALUE="new_item" TYPE="hidden">',
      '<FORM NAME="stdform" METHOD="POST" ACTION="http://www.ywesee.com" ACCEPT-CHARSET="UTF-8" ENCTYPE="application/x-www-form-urlencoded">',
      '<INPUT TYPE="hidden" NAME="state_id" VALUE="1">',
    ]
    expectations.each_with_index { |expected, idx|
			assert_not_nil(result.index(expected), "#{idx} missing:\n#{expected}\nin:\n#{result}")
		}
	end
end
