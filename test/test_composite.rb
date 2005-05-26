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
# TestComposite -- htmlgrid -- 24.10.2002 -- hwyss@ywesee.com 

$: << File.expand_path('../lib', File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'test/unit'
require 'stub/cgi'
require 'htmlgrid/composite'
require 'htmlgrid/inputtext'
require 'htmlgrid/form'

class StubComposite < HtmlGrid::Composite
	attr_writer :container
	COMPONENTS = {
		[0,0]		=>	:baz,
		[0,0,1]	=>	:foo,
		[0,0,2]	=>	:baz,
		[0,1]		=>	:baz,
		[0,1,1]	=>	:baz,	
	}
	LABELS = true
	SYMBOL_MAP = {
		:bar	=>	HtmlGrid::InputText,
	}
	attr_reader :model, :session
	public :resolve_offset, :labels?
	def init
		@barcount=0
		super
	end
	def foo(model, lookandfeel)
		"Foo"
	end
	def baz(model, lookandfeel)
		@barcount += 1
		"Baz#{@barcount}"
	end
end
class StubCompositeComponent < HtmlGrid::Component
	def to_html(context)
		context.a(@attributes) { 'brafoo' }
	end
end
class StubComposite2 < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	StubCompositeComponent,
	}
end
class StubComposite3 < StubComposite2
	COMPONENT_CSS_MAP = {[0,0,4,4]=>'standard'}
end
class StubComposite4 < StubComposite3
	CSS_MAP = {[0,0]=>'dradnats'}
	COMPONENT_CSS_MAP = {[0,0,4,4]=>'standard'}
end
class StubCompositeNoLabel < HtmlGrid::Composite
	LABELS = false
	COMPONENTS = {}
	public :labels?
end
class StubCompositeModel
end
class StubCompositeLookandfeel
	def attributes(key)
		{}
	end
	def lookup(key)
	end
	def base_url
		'http://www.oddb.org/de/gcc'
	end
end
class StubCompositeSession
	def lookandfeel
		StubCompositeLookandfeel.new
	end
end
class StubCompositeForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]	=>	StubComposite
	}
	EVENT = :foo
end
class StubCompositeColspan1 < HtmlGrid::Composite
	COMPONENTS = {}	
end
class StubCompositeColspan2 < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:foo,
	}	
end
class StubCompositeColspan3 < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:foo,
		[1,0]	=>	:bar,
	}	
end
class StubCompositeColspan4 < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:foo,
		[2,0]	=>	:bar,
	}	
end

class TestComposite < Test::Unit::TestCase
	def setup
		@composite = StubComposite.new(StubCompositeModel.new, StubCompositeSession.new)
	end
	def test_create_method
		foo = nil
		assert_nothing_raised {
			foo = @composite.create(:foo, @composite.model, nil)
		}
		assert_equal("Foo", foo)
	end
	def test_create_symbol
		bar = nil
		assert_nothing_raised {
			bar = @composite.create(:bar, @composite.model, StubCompositeLookandfeel.new)
		}
		assert_equal(HtmlGrid::InputText, bar.class)
	end
	def test_full_colspan1
		composite = StubCompositeColspan1.new(StubCompositeModel.new, StubCompositeSession.new)
		assert_nothing_raised { composite.full_colspan }
		assert_equal(nil, composite.full_colspan)
	end
	def test_full_colspan2
		composite = StubCompositeColspan2.new(StubCompositeModel.new, StubCompositeSession.new)
		assert_nothing_raised { composite.full_colspan }
		assert_equal(nil, composite.full_colspan)
	end
	def test_full_colspan3
		composite = StubCompositeColspan3.new(StubCompositeModel.new, StubCompositeSession.new)
		assert_nothing_raised { composite.full_colspan }
		assert_equal(2, composite.full_colspan)
	end
	def test_full_colspan4
		composite = StubCompositeColspan4.new(StubCompositeModel.new, StubCompositeSession.new)
		assert_nothing_raised { composite.full_colspan }
		assert_equal(3, composite.full_colspan)
	end
	def test_labels1
		composite = StubCompositeNoLabel.new(StubCompositeModel.new, StubCompositeSession.new)
		assert_equal(false, composite.labels?)
	end
	def test_labels2
		assert_equal(true, @composite.labels?)
	end
	def test_to_html
		expected = '<TABLE cellspacing="0"><TR><TD>Baz1FooBaz2</TD></TR><TR><TD>Baz3Baz4</TD></TR></TABLE>'
		assert_equal(expected, @composite.to_html(CGI.new))
	end
	def test_resolve_offset
		matrix = [1,2,3,4]
		assert_equal(matrix, @composite.resolve_offset(matrix))
		offset = [5,6]
		expected = [6,8,3,4]
		assert_equal(expected, @composite.resolve_offset(matrix, offset))
	end
	def test_event
		assert_nothing_raised { @composite.event() }
		form = StubCompositeForm.new(@composite.model, @composite.session)
		@composite.container = form
		assert_equal(:foo, @composite.event())
	end
	def test_component_css_map
		composite = StubComposite2.new(StubCompositeModel.new, StubCompositeSession.new)
		expected = '<TABLE cellspacing="0"><TR><TD><A>brafoo</A></TD></TR></TABLE>'
		assert_equal(expected, composite.to_html(CGI.new))
		composite = StubComposite3.new(StubCompositeModel.new, StubCompositeSession.new)
		expected = '<TABLE cellspacing="0"><TR><TD><A class="standard">brafoo</A></TD></TR></TABLE>'
		assert_equal(expected, composite.to_html(CGI.new))
		composite = StubComposite4.new(StubCompositeModel.new, StubCompositeSession.new)
		expected = '<TABLE cellspacing="0"><TR><TD class="dradnats"><A class="standard">brafoo</A></TD></TR></TABLE>'
		assert_equal(expected, composite.to_html(CGI.new))
	end
end
