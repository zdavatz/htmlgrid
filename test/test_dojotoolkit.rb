#!/usr/bin/env ruby
#
# HtmlGrid -- HyperTextMarkupLanguage Framework
# Copyright (C) 2003 ywesee - intellectual capital connected
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
# ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zuerich, Switzerland
# htmlgrid@ywesee.com, www.ywesee.com/htmlgrid
#

$: << File.expand_path('../lib', File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'minitest/autorun'
require 'stub/cgi'
require 'htmlgrid/dojotoolkit'
require 'test_helper'
require 'flexmock/minitest'

class TestDojotoolkit < Minitest::Test
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
    @session = flexmock('session') do |s|
      s.should_receive(:user_agent).and_return('user_agent').by_default
    end
    @cgi = CGI.new
  end
  def test_dynamic_html
    comp = HtmlGrid::Component.new("foo", @session)
    comp.dojo_tooltip = 'my_tooltip'
    assert_equal("foo", comp.model)
    assert_equal(false, comp.label?)
    result= comp.dynamic_html(@cgi)
    assert(/href="my_tooltip"/.match(result))
  end
  def test_dynamic_html_with_msie
    @session.should_receive(:user_agent).and_return('MSIE 4')
    comp = HtmlGrid::Component.new("foo", @session)
    comp.dojo_tooltip = 'my_tooltip'
    assert_equal("foo", comp.model)
    assert_equal(false, comp.label?)
    result= comp.dynamic_html(@cgi)
    assert(/href="my_tooltip"/.match(result))
  end
end
