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
# TestGrid -- htmlgrid -- hwyss@ywesee.com

$: << File.expand_path("../lib", File.dirname(__FILE__))
$: << File.expand_path("../ext", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'test/unit'
if /java/i.match(RUBY_PLATFORM)
  puts "Skipping rebuild for JRUBY"
else
  require 'rebuild'
end
require 'stub/cgi'
require 'htmlgrid/label'
require 'htmlgrid/grid'

module HtmlGrid
	class Grid
		class Row
			class Field
				attr_reader :attributes
			end
		end
	end
end	

class TestGrid < Test::Unit::TestCase
	class StubLabel
		include Enumerable
		def each
			yield "foo"
			yield "bar"
		end
		def to_html(cgi)
			"foo"
		end
	end
	class StubGridComponent
		attr_reader :attributes
		def initialize
			@attributes = {"class"	=>	"foo"}
		end
		def to_html(context)
			"bar"
		end
		def set_attribute(key, value)
			@attributes.store(key, value)
		end
	end
	class StubNilComponent
		attr_reader :attributes
		def initialize
			@attributes = {}
		end
		def to_html(context)
			nil
		end
	end
  def setup
    @grid = HtmlGrid::Grid.new
  end
  def test_initialize
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR></TABLE>'
		assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add
    @grid.add("test", 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add2
    @grid.add(nil, 0, 0)
    @grid.add(nil, 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add3
    @grid.add(2, 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_field
    @grid.add_field("test", 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
	def test_add_multiple
	  @grid.add("test", 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
	  @grid.add("foo", 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>testfoo</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_add_multiple__2
	  @grid.add(["test", "foo"], 0, 0)
    assert_equal(1, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>testfoo</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_add_multiple__3
	  @grid.add(["test", nil, "foo"], 0, 0)
    assert_equal(2, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>test</TD><TD>foo</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
  def test_add_fieldx
    @grid.add("test", 1, 0)
    assert_equal(2, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_fieldy
    @grid.add("test", 0, 1)
    assert_equal(1, @grid.width)
    assert_equal(2, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR><TR><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_fieldxy
    @grid.add("test", 1, 1)
    assert_equal(2, @grid.width)
    assert_equal(2, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_fieldyx
    @grid.add("test", 0, 1)
    @grid.add("test", 1, 0)
    assert_equal(2, @grid.width)
    assert_equal(2, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>test</TD></TR><TR><TD>test</TD><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))

  end
  def test_add_row1
    @grid.add_row(["test1", "test2"], 0,0)
    assert_equal(2, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>test1</TD><TD>test2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_row2
    @grid.add_row(["test1", "test2"], 0,1)
    assert_equal(2, @grid.width)
    assert_equal(2, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR><TR><TD>test1</TD><TD>test2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_row3
    @grid.add_row(["test1", "test2"], 1,0)
    assert_equal(3, @grid.width)
    assert_equal(1, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>test1</TD><TD>test2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_column1
    @grid.add_column(["test1", "test2"], 0,0)
    assert_equal(1, @grid.width)
    assert_equal(2, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>test1</TD></TR><TR><TD>test2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_column2
    @grid.add_column(["test1", "test2"], 0,1)
    assert_equal(1, @grid.width)
    assert_equal(3, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR><TR><TD>test1</TD></TR><TR><TD>test2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
  def test_add_column3
    @grid.add_column(["test1", "test2"], 1,0)
    assert_equal(2, @grid.width)
    assert_equal(2, @grid.height)
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>test1</TD></TR><TR><TD>&nbsp;</TD><TD>test2</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
  end
	def test_add_tag1
		@grid.add_tag('TH', 0, 0)
		expected = '<TABLE cellspacing="0"><TR><TH>&nbsp;</TH></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_add_tag2
		@grid.add_tag('TH', 0, 0, 2)
		expected = '<TABLE cellspacing="0"><TR><TH>&nbsp;</TH><TH>&nbsp;</TH></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_add_tag3
		@grid.add_tag('TH', 0, 0, 1, 2)
		expected = '<TABLE cellspacing="0"><TR><TH>&nbsp;</TH></TR><TR><TH>&nbsp;</TH></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_add_component_style
		thing = StubGridComponent.new
		@grid.add(thing, 1,1)
		@grid.add_component_style('foobar', 0,0,2,2)
		assert_equal('foobar', thing.attributes['class'])
	end
	def test_add_style
		@grid.add_style('foo', 0,0)
		expected = '<TABLE cellspacing="0"><TR><TD class="foo">&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
		@grid.add(nil, 1,1)
		@grid.add_style('bar', 0, 1, 2)	
		expected = '<TABLE cellspacing="0"><TR><TD class="foo">&nbsp;</TD>'
		expected << '<TD>&nbsp;</TD></TR><TR><TD class="bar">&nbsp;</TD>'
		expected << '<TD class="bar">&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
		@grid.add_style('foobar', 0,0,2,2)
		expected = '<TABLE cellspacing="0"><TR><TD class="foobar">&nbsp;</TD>'
		expected << '<TD class="foobar">&nbsp;</TD></TR>'
		expected << '<TR><TD class="foobar">&nbsp;</TD>'
		expected << '<TD class="foobar">&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_add_attribute
		@grid.add_attribute('foo', 'bar', 0, 0)
		expected = '<TABLE cellspacing="0"><TR><TD foo="bar">&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_colspan1
		assert_nothing_raised { @grid.set_colspan(1,1,2) }
		expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD colspan="2">&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_colspan2
    @grid.add("test", 2, 2)
		assert_nothing_raised { @grid.set_colspan(0,0) }
		expected = '<TABLE cellspacing="0"><TR><TD colspan="3">&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
		assert_nothing_raised { @grid.set_colspan(1,1) }
		expected = '<TABLE cellspacing="0"><TR><TD colspan="3">&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD colspan="2">&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD>&nbsp;</TD><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_push
		@grid.add("bar",4,0)
		@grid.push("foo")
		expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>&nbsp;</TD>'
		expected << '<TD>&nbsp;</TD><TD>&nbsp;</TD><TD>bar</TD></TR>'
		expected << '<TR><TD colspan="5">foo</TD></TR></TABLE>'
		assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_matrix
		matrix = [1,1]
		assert_nothing_raised { 
			@grid.add("test", *matrix)
		}
    expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR><TR><TD>&nbsp;</TD><TD>test</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_attributes
		### this test has changed behavior: its not desirable to have magically 
		### transferred css information from a component to its container
		@grid.add(StubGridComponent.new, 0,0)
		expected = '<TABLE cellspacing="0"><TR><TD>bar</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_attribute1
		@grid.set_attribute("foo", "bar")
		expected = '<TABLE cellspacing="0" foo="bar"><TR><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_attribute2
		@grid.set_attribute("foo", nil)
		expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_attributes
		hash = {"foo"=>"bar", "baz"=>"bash"}
		@grid.set_attributes(hash)
		expected = [
			'<TABLE cellspacing="0" foo="bar" baz="bash"><TR><TD>&nbsp;</TD></TR></TABLE>',
			'<TABLE cellspacing="0" baz="bash" foo="bar"><TR><TD>&nbsp;</TD></TR></TABLE>',
		]
		result = @grid.to_html(CGI.new)
    assert_equal(true, expected.include?(result), result)
	end
	def test_set_row_attributes1
		@grid.set_row_attributes({'foo' => 'bar'}, 0)
		expected = '<TABLE cellspacing="0"><TR foo="bar"><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_row_attributes2
		@grid.set_row_attributes({'foo' => 'bar'}, 1)
		expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR><TR foo="bar"><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_set_row_attributes3
		@grid.set_row_attributes({'foo' => 'bar'}, 1, 2)
		expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR><TR foo="bar"><TD>&nbsp;</TD></TR><TR foo="bar"><TD>&nbsp;</TD></TR></TABLE>'
    assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_insert_row
		assert_equal(1, @grid.height)
		@grid.add("testfeld", 0, 1)
		assert_equal(2, @grid.height)
		expected = '<TABLE cellspacing="0"><TR><TD>&nbsp;</TD></TR><TR><TD>testfeld</TD></TR></TABLE>'
		assert_equal(expected, @grid.to_html(CGI.new))
		@grid.insert_row(0, "testreihe")
		assert_equal(3, @grid.height)
		expected = '<TABLE cellspacing="0"><TR><TD>testreihe</TD></TR><TR><TD>&nbsp;</TD></TR><TR><TD>testfeld</TD></TR></TABLE>'
		assert_equal(expected, @grid.to_html(CGI.new))
	end
	def test_gc
		100.times { |y|
			200.times { |x|
				str = "[#{x}, #{y}]: test"
				@grid.add(str, x, y)
				@grid.add(str, x, y)
				@grid.add(str, x, y)
				@grid.add(str, x, y)
			}
		}
		assert_equal(100, @grid.height)
		assert_equal(200, @grid.width)
		result = @grid.to_html(CGI.new)
	end
	def test_label
		label = StubLabel.new
		@grid.add(label, 0,0)
		result = @grid.to_html(CGI.new)
		assert_equal('<TABLE cellspacing="0"><TR><TD>foo</TD><TD>bar</TD></TR></TABLE>', result)
	end
	def test_field_attribute
		@grid.add_attribute('foo', 'bar', 0, 0)
		assert_equal('bar', @grid.field_attribute('foo', 0, 0))
	end
	def test_nil_attribute1
		@grid.add_attribute('foo', nil, 0, 0)
		assert_nothing_raised {
			@grid.to_html(CGI.new)
		}
	end
	def test_nil_attribute2
		thing = StubGridComponent.new
		thing.set_attribute("class", nil)	
		@grid.add(thing, 0,0)
		assert_nothing_raised {
			@grid.to_html(CGI.new)
		}
	end
	def test_nil_component
		thing = StubNilComponent.new
		@grid.add(thing, 0,0)
		assert_nothing_raised {
			@grid.to_html(CGI.new)
		}
	end
	def test_add_negative
		assert_raises(ArgumentError) { @grid.add('foo', -1, 0) }
		assert_raises(ArgumentError) { @grid.add('foo', 0, -1) }
		assert_raises(ArgumentError) { @grid.add(['foo', 'bar'], -1, 0) }
		assert_raises(ArgumentError) { @grid.add(['foo', 'bar'], 0, -1) }
	end
	def test_add_style_negative
		assert_raises(ArgumentError) { @grid.add_style('bar', -1, 1) }
		assert_raises(ArgumentError) { @grid.add_style('bar', 1, -1) }
		assert_raises(ArgumentError) { @grid.add_style('bar', 1, 1, -1) }
		assert_raises(ArgumentError) { @grid.add_style('bar', 1, 1, 1,-1) }
	end
end
