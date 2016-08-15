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
# TestComposite -- htmlgrid -- 24.10.2002 -- hwyss@ywesee.com

$: << File.expand_path('../lib', File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'minitest/autorun'
require 'stub/cgi'
require 'htmlgrid/composite'
require 'htmlgrid/inputtext'
require 'htmlgrid/form'
require 'htmlgrid/button'
require 'test_helper'

module CompositeTest
  class StubComposite < HtmlGrid::Composite
    attr_writer :container
    COMPONENTS = {
      [0, 0, 0] => :baz,
      [0, 0, 1] => :foo,
      [0, 0, 2] => :baz,
      [0, 1, 0] => :baz,
      [0, 1, 1] => :baz,
    }
    LABELS = true
    SYMBOL_MAP = {
      :bar => HtmlGrid::InputText,
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
    def back
      super
    end
  end
  class StubCompositeComponent < HtmlGrid::Component
    def to_html(context)
      context.a(@attributes) { 'brafoo' }
    end
  end
  class StubComposite2 < HtmlGrid::Composite
    COMPONENTS = {
      [0, 0] => StubCompositeComponent,
    }
  end
  class StubComposite3 < StubComposite2
    COMPONENT_CSS_MAP = {[0, 0, 4, 4] => 'standard'}
  end
  class StubComposite4 < StubComposite3
    CSS_MAP = {[0, 0] => 'dradnats'}
    COMPONENT_CSS_MAP = {[0, 0, 4, 4] => 'standard'}
  end
  class StubCompositeNoLabel < HtmlGrid::Composite
    LABELS = false
    COMPONENTS = {}
    public :labels?
  end
  class StubCompositeModel
    def qux
      'qux'
    end
  end
  class StubCompositeLookandfeel
    def event_url(one)
      return 'event_url'
    end
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
    def error(key)
    end
  end

  class StubCompositeSession2 < StubCompositeSession; end

  class StubCompositeForm < HtmlGrid::Form
    COMPONENTS = {
      [0, 0] => StubComposite
    }
    EVENT = :foo
  end
  class StubCompositeColspan1 < HtmlGrid::Composite
    COMPONENTS = {}
  end
  class StubCompositeColspan2 < HtmlGrid::Composite
    COMPONENTS = {
      [0, 0] => :foo,
    }
  end
  class StubCompositeColspan3 < HtmlGrid::Composite
    COMPONENTS = {
      [0, 0] => :foo,
      [1, 0] => :bar,
    }
  end
  class StubCompositeColspan4 < HtmlGrid::Composite
    COMPONENTS = {
      [0, 0] => :foo,
      [2, 0] => :bar,
    }
  end

  class TestComposite < Minitest::Test
    def setup
      @composite = StubComposite.new(
        StubCompositeModel.new, StubCompositeSession.new)
    end

    def test_component_session_fallback_assignment_without_session_argment
      StubComposite.component(StubComposite, :qux)
      model    = StubCompositeModel.new
      session1 = StubCompositeSession.new
      composite = StubComposite.new(model, session1)
      # via instance variable (without argument)
      composite = composite.compositetest_stubcomposite_qux(model)
      assert_kind_of(StubCompositeSession, composite.session)
      assert_equal(session1, composite.session)
      # via argument
      session2 = StubCompositeSession2.new
      composite = composite.compositetest_stubcomposite_qux(model, session2)
      assert_kind_of(StubCompositeSession2, composite.session)
      assert_equal(session2, composite.session)
    end

    def test_create_method
      foo = nil
      foo = @composite.create(:foo, @composite.model)
      assert_equal("Foo", foo)
    end
    def test_create_symbol
      bar = nil
      bar = @composite.create(:bar, @composite.model)
      assert_equal(HtmlGrid::InputText, bar.class)
    end
    def test_full_colspan1
      composite = StubCompositeColspan1.new(
        StubCompositeModel.new, StubCompositeSession.new)
      composite.full_colspan
      assert_equal(nil, composite.full_colspan)
    end
    def test_full_colspan2
      composite = StubCompositeColspan2.new(
        StubCompositeModel.new, StubCompositeSession.new)
      composite.full_colspan
      assert_equal(nil, composite.full_colspan)
    end
    def test_full_colspan3
      composite = StubCompositeColspan3.new(
        StubCompositeModel.new, StubCompositeSession.new)
      composite.full_colspan
      assert_equal(2, composite.full_colspan)
    end
    def test_full_colspan4
      composite = StubCompositeColspan4.new(
        StubCompositeModel.new, StubCompositeSession.new)
      composite.full_colspan
      assert_equal(3, composite.full_colspan)
    end
    def test_labels1
      composite = StubCompositeNoLabel.new(
        StubCompositeModel.new, StubCompositeSession.new)
      assert_equal(false, composite.labels?)
    end
    def test_labels2
      assert_equal(true, @composite.labels?)
    end
    def test_to_html
      assert_equal(<<-EXP.gsub(/\n|^\s*/, ''), @composite.to_html(CGI.new))
        <TABLE cellspacing="0">
          <TR><TD>Baz1FooBaz2</TD></TR><TR><TD>Baz3Baz4</TD></TR>
        </TABLE>
      EXP
    end
    def test_resolve_offset
      matrix = [1,2,3,4]
      assert_equal(matrix, @composite.resolve_offset(matrix))
      offset = [5,6]
      expected = [6,8,3,4]
      assert_equal(expected, @composite.resolve_offset(matrix, offset))
    end
    def test_event
      @composite.event
      @composite.container = StubCompositeForm.new(
        @composite.model, @composite.session)
      assert_equal(:foo, @composite.event)
    end
    def test_component_css_map
      table = StubComposite2.new(
        StubCompositeModel.new, StubCompositeSession.new)
      assert_equal(<<-EXP.gsub(/\n|^\s*/, ''), table.to_html(CGI.new))
        <TABLE cellspacing="0">
          <TR><TD><A>brafoo</A></TD></TR>
        </TABLE>
      EXP
      table = StubComposite3.new(
        StubCompositeModel.new, StubCompositeSession.new)
      assert_equal(<<-EXP.gsub(/\n|^\s*/, ''), table.to_html(CGI.new))
        <TABLE cellspacing="0">
          <TR><TD><A class="standard">brafoo</A></TD></TR>
        </TABLE>
      EXP
      table = StubComposite4.new(
        StubCompositeModel.new, StubCompositeSession.new)
      assert_equal(<<-EXP.gsub(/\n|^\s*/, ''), table.to_html(CGI.new))
        <TABLE cellspacing="0">
          <TR><TD><A class="standard">brafoo</A></TD></TR>
        </TABLE>
      EXP
    end
    def test_to_back
      if RUBY_VERSION.split(".").first.eql?('1')
        expected = <<-EXP.gsub(/\n|^\s{10}/, '')
          <INPUT type="button" name="back"
           onClick="document.location.href='event_url';">
        EXP
      else
        # It looks like Ruby 2.x escapes the ' which is not strictly necessary
        expected = <<-EXP.gsub(/\n|^\s{10}/, '')
          <INPUT type="button" name="back"
           onClick="document.location.href=&#39;event_url&#39;;">
        EXP
      end
      html = @composite.back().to_html(CGI.new)
      assert_equal(expected, html)
    end
  end
end
