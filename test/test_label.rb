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
# TestLabel -- htmlgrid -- 26.11.2002 -- hwyss@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../lib", File.dirname(__FILE__))

require "minitest/autorun"
require "stub/cgi"
require "htmlgrid/label"
require "htmlgrid/composite"

class TestLabel < Minitest::Test
  class StubLabelState
    attr_reader :errors
    def initialize(errors = {})
      @errors = errors
    end
  end

  class StubLabelModel
  end

  class StubLabelSession
    attr_writer :state
    def state
      @state ||= StubLabelState.new
    end

    def lookup(key)
      case key
      when :componentname
        "Label"
      when :named_component
        "Named Label"
      end
    end

    def lookandfeel
      self
    end

    def error(key)
      state.errors[key]
    end
  end

  class StubLabelComponent < HtmlGrid::Component
    attr_accessor :mey
    def initialize(model, session = nil, container = nil)
      @mey = nil
      super
    end

    def to_html(context)
      "component"
    end

    def label?
      true
    end

    def name
      :componentname
    end

    def css_class
      @mey
    end
  end

  class StubLabelComposite < HtmlGrid::Composite
    COMPONENTS = {
      [0, 0]	=>	StubLabelComponent,
      [0, 1]	=>	:named_component
    }
    LABELS = true
    def named_component(model, session)
      @named_component ||= StubLabelComponent.new(model, session, self)
    end
  end

  def	setup
    @session = StubLabelSession.new
    # @label = HtmlGrid::Label.new(component)
  end

  def test_to_html1
    composite = StubLabelComposite.new(StubLabelModel.new, @session)
    expected = '<TABLE cellspacing="0"><TR>'
    expected += '<TD><LABEL for="componentname">Label</LABEL></TD>'
    expected += "<TD>component</TD></TR>"
    expected += '<TR><TD><LABEL for="componentname">Named Label</LABEL></TD>'
    expected += "<TD>component</TD></TR></TABLE>"
    assert_equal(expected, composite.to_html(CGI.new))
  end

  def test_to_html2
    @session.state = StubLabelState.new({named_component: "ein Error"})
    composite = StubLabelComposite.new(StubLabelModel.new, @session)
    expected = '<TABLE cellspacing="0"><TR><TD><LABEL for="componentname">Label</LABEL></TD><TD>component</TD></TR><TR><TD><LABEL for="componentname" class="error">Named Label</LABEL></TD><TD>component</TD></TR></TABLE>'
    assert_equal(expected, composite.to_html(CGI.new))
  end
end
