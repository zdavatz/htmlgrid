#!/usr/bin/env ruby
#
#	HtmlGrid -- HyperTextMarkupLanguage Framework
#	Copyright (C) 2003 ywesee - intellectual capital connected
# Hannes Wyss
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
# TestComponent -- htmlgrid -- 26.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path("../lib", File.dirname(__FILE__))
$: << File.expand_path("../ext", File.dirname(__FILE__))

require 'test/unit'
require 'htmlgrid/component'

module HtmlGrid
	class Component
		attr_reader :model, :session, :container
	end
end

class TestComponent < Test::Unit::TestCase
	class StubAttributeComponent < HtmlGrid::Component
		HTML_ATTRIBUTES = { "key" => "val" }
	end
	class StubInitComponent < HtmlGrid::Component
		attr_reader :init_called
		def init
			@init_called = true
		end
	end
	class StubLabelComponent < HtmlGrid::Component
		LABEL = true
	end
	class StubContainer
		attr_accessor :onsubmit
	end
	def setup
		@component = HtmlGrid::Component.new(nil, nil)
	end
	def test_initialize1
		assert_nothing_raised {
			HtmlGrid::Component.new("foo", "bar")
		}
		comp = HtmlGrid::Component.new("foo", "bar")
		assert_equal("foo", comp.model)
		assert_equal("bar", comp.session)
		assert_equal(nil, comp.container)
		assert_equal(false, comp.label?)
		assert_nothing_raised {
			comp.label = true
		}
		assert_equal(true, comp.label?)
	end
	def test_initialize2
		assert_nothing_raised {
			HtmlGrid::Component.new("foo", "bar", "baz")
		}
		comp = HtmlGrid::Component.new("foo", "bar", "baz")
		assert_equal("foo", comp.model)
		assert_equal("bar", comp.session)
		assert_equal("baz", comp.container)
	end
	def test_initialize3
		comp = StubAttributeComponent.new("foo", "bar")
		expected = { "key" =>	"val" }
		assert_respond_to(comp, :attributes)
		assert_equal(expected, comp.attributes)
		assert_equal(expected, StubAttributeComponent::HTML_ATTRIBUTES)
		assert_nothing_raised {
			comp.attributes.store("other", "val")
		}
		expected2 = { "key" =>	"val", "other" => "val" }
		assert_equal(expected2, comp.attributes)
		assert_equal(expected, StubAttributeComponent::HTML_ATTRIBUTES)
		assert_equal({}, @component.attributes)
		assert_equal({}, HtmlGrid::Component::HTML_ATTRIBUTES)
		assert_nothing_raised {
			@component.attributes.store("third", "val")
		}
		expected = {"third"=>"val"}
		assert_equal(expected, @component.attributes)
		assert_equal({}, HtmlGrid::Component::HTML_ATTRIBUTES)
	end
	def test_initialize4
		comp = StubInitComponent.new("foo", "bar")
		assert_equal(true, comp.init_called)
	end
	def test_initialize5
		comp = StubLabelComponent.new(nil, nil)
		assert_equal(true, comp.label?)
	end
	def test_escape
		txt = "Guten Tag! & wie gehts uns denn heute? '<' schlechter oder '>' besser?"
		control = txt.dup
		expected = "Guten Tag! &amp; wie gehts uns denn heute? '&lt;' schlechter oder '&gt;' besser?"
		assert_equal(expected, @component.escape(txt))
		assert_equal(control, txt)
		assert_equal(expected, @component.escape(txt))
	end
	def test_escape_symbols
		txt = "\263"
		expected = "&ge;"
		assert_equal(expected, @component.escape_symbols(txt))
	end
	def test_onsubmit
		@component.onsubmit = 'submitted'
		assert_equal({}, @component.attributes)
		cont = StubContainer.new
		comp = HtmlGrid::Component.new("foo", "bar", cont)
		comp.onsubmit = 'submitted'
		assert_equal('submitted', cont.onsubmit)
	end
	def test_set_attribute
		assert_equal({}, @component.attributes)
		@component.set_attribute('href', 'http://www.ywesee.com')
		expected = {
			'href'	=>	'http://www.ywesee.com',
		}
		assert_equal(expected, @component.attributes)
	end
end
