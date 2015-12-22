#!/usr/bin/env ruby
#encoding: utf-8
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
    [0,0,1] =>  :foo,
  }
  LABELS = true
  SYMBOL_MAP = {
    :bar  =>  HtmlGrid::InputText,
  }
  attr_reader :model, :session
  public :resolve_offset, :labels?
  def init
    @barcount=0
    super
  end
  def foo(model)
    1.upto(2).each { |idx| 
                      @grid.add(baz(model), 0, idx, 0)
    }
    "Foo"
  end
  def baz(model)
    @barcount += 1
    "Baz#{@barcount}"
  end
end
class StubCompositeModel
end
class StubComposite2Model
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
  def error(key)
  end
end
class StubCompositeForm < HtmlGrid::Form
  COMPONENTS = {
    [0,0] =>  StubComposite
  }
  EVENT = :foo
end

class TestComposite < Test::Unit::TestCase
  def setup
    @composite = StubComposite.new([StubComposite2Model.new, StubCompositeModel.new], 
                                   StubCompositeSession.new)
  end
  def test_to_html
    expected = '<TABLE cellspacing="0"><TR><TD>Foo</TD></TR><TR><TD>Baz1</TD></TR><TR><TD>Baz2</TD></TR></TABLE>'
    assert_equal(expected, @composite.to_html(CGI.new))
  end
end
