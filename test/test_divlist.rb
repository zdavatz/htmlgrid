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

require "minitest/autorun"
require "htmlgrid/divlist"
require "stub/cgi"
require "test_helper"

module HtmlGrid
  class DivList < DivComposite
    attr_reader :grid
  end
end

class StubDivList < HtmlGrid::DivList
  attr_reader :model
  COMPONENTS = {
    [0, 0]	=>	:jaguar,
    [1, 0]	=>	:panther
  }
  CSS_MAP = {
    [0, 0]	=>	"flecken",
    [1, 0]	=>	"schwarz"
  }
  SORT_HEADER = false
  SORT_DEFAULT = :foo
end

class StubDivListLookandfeel
  def lookup(key)
    key
  end

  def attributes(key)
    {}
  end
end

class StubDivListSession
  attr_accessor :event
  def lookandfeel
    StubDivListLookandfeel.new
  end
end

class StubDivListModel
  attr_reader :foo
  def initialize(foo)
    @foo = foo
  end

  def jaguar
    "Jaguar"
  end

  def panther
    "Panther"
  end
end

class StubDivListEmpty
  attr_reader :foo
  def initialize(foo)
    @foo = foo
  end
end

class TestDivList < Minitest::Test
  def setup
    model = [
      StubDivListModel.new(3),
      StubDivListModel.new(2),
      StubDivListModel.new(4),
      StubDivListModel.new(1),
      StubDivListModel.new(nil)
    ]
    @list = StubDivList.new(model, StubDivListSession.new)
  end

  def test_nil_robust
    list = StubDivList.new(nil, StubDivListSession.new)
    assert_equal("", list.to_html(CGI.new))
  end

  def test_to_html
    expected = "<DIV>JaguarPanther</DIV><DIV>JaguarPanther</DIV><DIV>JaguarPanther</DIV><DIV>JaguarPanther</DIV><DIV>JaguarPanther</DIV>"
    assert_equal(expected, @list.to_html(CGI.new))
  end

  def test_nil_robust_to_html
    list = StubDivList.new([nil], StubDivListSession.new)
    expected = "<DIV></DIV>"
    assert_equal(expected, list.to_html(CGI.new))
  end

  def test_nil_robust_to_html2
    list = StubDivList.new([], StubDivListSession.new)
    expected = ""
    assert_equal(expected, list.to_html(CGI.new))
  end
end
