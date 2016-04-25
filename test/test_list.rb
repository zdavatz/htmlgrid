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
# TestList -- htmlgrid -- 03.03.2003 -- hwyss@ywesee.com 

$: << File.dirname(__FILE__)
$: << File.expand_path("../lib", File.dirname(__FILE__))

require 'minitest/autorun'
require 'htmlgrid/list'
require 'stub/cgi'

module HtmlGrid
	class Grid
		class Row
			class Field
				attr_reader	:attributes
			end
		end
	end
	class List < Composite
		attr_reader :grid
		public :lookandfeel_key
	end
end
class StubListViewColumnNames < HtmlGrid::List
	LOOKANDFEEL_MAP = {
		:raffi	=>	:waltert,
		:andy		=>	:schrafl,
	}
	COMPONENTS = {}
end
class StubList < HtmlGrid::List
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
class StubListLookandfeel
	def lookup(key)
		key
	end
	def attributes(key)
		{}
	end
end
class StubListSession
	attr_accessor :event
	def lookandfeel
		StubListLookandfeel.new
	end
end
class StubListModel
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

class TestList < Minitest::Test
	def setup
		model = [
			StubListModel.new(3),
			StubListModel.new(2),
			StubListModel.new(4),
			StubListModel.new(1),
		]
		@list = StubList.new(model, StubListSession.new)
	end
	def test_compose
		@list.compose
		assert_equal(5, @list.grid.height)
		assert_equal(2, @list.grid.width)
	end
	def test_default_sort
		foos = @list.model.collect { |item| item.foo }
		expected = [ 1,2,3,4 ]
		assert_equal(expected, foos)
	end
	def test_header
		expected = '<TABLE cellspacing="0"><TR><TH title="th_jaguar_title">th_jaguar</TH><TH title="th_panther_title">th_panther</TH>'
		assert_equal(0, @list.to_html(CGI.new).index(expected))
	end
	def test_lookandfeel_key
		list = StubListViewColumnNames.new([], StubListSession.new)
		assert_equal(:waltert, list.lookandfeel_key(:raffi))	
		assert_equal(:hannes, list.lookandfeel_key(:hannes))	
	end
	def test_nil_robust
    StubList.new(nil, StubListSession.new)
	end
	def test_suffix
		@list.compose
		expected = {
			[0,1]	=>	"flecken",
			[1,1]	=>	"schwarz",
			[0,2]	=>	"flecken-bg",
			[1,2]	=>	"schwarz-bg",
			[0,3]	=>	"flecken",
			[1,3]	=>	"schwarz",
			[0,4]	=>	"flecken-bg",
			[1,4]	=>	"schwarz-bg",
		}
		expected.each { |key, value|
			assert_equal(value, @list.grid.field_attribute("class", *key))
		}
	end
	def test_title
		assert_equal('th_jaguar_title', @list.grid.field_attribute('title', 0, 0))
	end
end
