#!/usr/bin/env ruby
# encoding: utf-8
# A little bit more elaborated test of the list, where we add different lines
# Constructing can be a little tricky.
# Also shows one can choose a differnt background color for a line
# Added by Niklaus Giger who had to some improvemnts for the interaction_chooser
$: << File.expand_path('../lib', File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'minitest'
require 'test/unit'
require 'stub/cgi'
require 'htmlgrid/composite'
require 'htmlgrid/inputtext'
require 'htmlgrid/form'
require 'htmlgrid/list'
require 'htmlgrid/div'

class StubComposite < HtmlGrid::Composite
  attr_writer :container
  COMPONENTS = {
    [0,0,0] =>  :baz,
    [0,0,1] =>  :foo,
    [0,0,2] =>  :baz,
    [0,1,0] =>  :baz,
    [0,1,1] =>  :baz, 
  }
  LABELS = true
  SYMBOL_MAP = {
    :bar  =>  HtmlGrid::InputText,
  }
  attr_reader :model, :session
  public :resolve_offset, :labels?
  def initialize(first, second, third = nil)
    super(first, second)
  end
  def init
    @barcount=0
    super
  end
  def foo(model, session)
    "Foo"
  end
  def baz(model, session)
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
    [0,0] =>  StubCompositeComponent,
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
  attr_accessor :event
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
class StubCompositeColspan1 < HtmlGrid::Composite
  COMPONENTS = {} 
end
class StubCompositeColspan2 < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] =>  :foo,
  } 
end
class StubCompositeColspan3 < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] =>  :foo,
    [1,0] =>  :bar,
  } 
end
class StubCompositeColspan4 < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] =>  :foo,
    [2,0] =>  :bar,
  } 
end

class StubInteractionChooserDrugList < HtmlGrid::List
  attr_reader :model, :value
  COMPONENTS = {
    [0,0] =>  :info_drug,
  } 
  CSS_MAP = {
    [0,0] =>  'css.info',
  }
  SORT_HEADER = false
  SORT_DEFAULT = :foo
  def initialize(models, session=@session)
    super # must come first or it will overwrite @value
    @value = []
    models.each{ |model|
                 @value << StubInteractionChooserDrug.new(model, session)
                 }
  end
  def to_html(context)
    div = HtmlGrid::Div.new(@model, @session, self)
    if @drugs and !@drugs.empty?
      delete_all_link = HtmlGrid::Link.new(:delete, @model, @session, self)
      delete_all_link.href  = @lookandfeel._event_url(:delete_all, [])
      delete_all_link.value = @lookandfeel.lookup(:interaction_chooser_delete_all)
      delete_all_link.css_class = 'list'
      div.value = delete_all_link
    end 
    div.set_attribute('id', 'drugs')
    @value << div unless @value.find{ |v| v.attributes['id'].eql?('drugs') }
    super
  end
end

class StubDrugModel
  attr_reader :foo
  def initialize(foo)
    @foo = foo
  end
  def fachinfo
    @foo
  end
  def drug
    'Drug'
  end
end 

class StubInteractionChooserDrugHeader < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :fachinfo,
    [1,0] => :atc,
    [2,0] => :delete,
  }
  CSS_MAP = {
    [0,0] => 'small',
    [1,0] => 'interaction-atc',
    [2,0] => 'small',
  }
  HTML_ATTRIBUTES = {
    'style' =>  'background-color:greenyellow',
  }
  def init
    super
  end
  def fachinfo(model, session=@session)
    "fachinfo-#{model.foo}"
  end
  def atc(model, session=@session)
    'atc'
  end
  def delete(model, session=@session)
    'delete'
  end
end
class StubInteractionChooserDrug < HtmlGrid::Composite
  COMPONENTS = {
    }
  CSS_MAP = {}
  CSS_CLASS = 'composite'
  @@barcode ||= 0
  def init
    @@barcode += 1
    components.store([0,0], :header_info)
    css_map.store([0,0], 'subheading')
    1.upto(@@barcode) { |idx|
      components.store([0,idx], :text_info)
    }
    @attributes.store('id', 'drugs_' + @@barcode.to_s)
    super
  end
  def header_info(model, session=@session)
    StubInteractionChooserDrugHeader.new(model, session, self)
  end
  def text_info(model, session=@session)
    "interaction for #{model.foo}"
  end
end
class TestComposite < Test::Unit::TestCase
  def setup
    @composite = StubComposite.new(StubCompositeModel.new, StubCompositeSession.new)
  end
  def test_create_method
    foo = nil
    assert_nothing_raised {
      foo = @composite.create(:foo, @composite.model)
    }
    assert_equal("Foo", foo)
  end
  def test_to_html
    expected = '<TABLE cellspacing="0"><TR><TD>Baz1FooBaz2</TD></TR><TR><TD>Baz3Baz4</TD></TR></TABLE>'
    assert_equal(expected, @composite.to_html(CGI.new))
  end
  def test_component_css_map
    composite = StubComposite2.new(StubCompositeModel.new, StubCompositeSession.new)
    expected = '<TABLE cellspacing="0"><TR><TD><A>brafoo</A></TD></TR></TABLE>'
    assert_equal(expected, composite.to_html(CGI.new))
    composite = StubComposite3.new(StubCompositeModel.new, StubCompositeSession.new)
    expected = '<TABLE cellspacing="0"><TR><TD><A class="standard">brafoo</A></TD></TR></TABLE>'
    assert_equal(expected, composite.to_html(CGI.new))
    composite = StubComposite4.new(StubCompositeModel.new, StubCompositeSession.new)
  end
  def test_interaction_list_to_html
    models = [  StubDrugModel.new('Aspirin'),
                StubDrugModel.new('Marcoumar'),
            ]
    composite = StubInteractionChooserDrugList.new(models, StubCompositeSession.new)
    expected =  [ '<TABLE cellspacing="0" class="composite" id="drugs_1">',
                  '<TR><TD class="subheading"><TABLE cellspacing="0" style="background-color:greenyellow">',
                  '<TR><TD class="small">fachinfo-Aspirin</TD><TD class="interaction-atc">atc</TD><TD class="small">delete</TD></TR></TABLE></TD></TR>',
                  '<TR><TD>interaction for Aspirin</TD></TR></TABLE> <TABLE cellspacing="0" class="composite" id="drugs_2">',
                  '<TR><TD class="subheading"><TABLE cellspacing="0" style="background-color:greenyellow">',
                  '<TR><TD class="small">fachinfo-Marcoumar</TD><TD class="interaction-atc">atc</TD><TD class="small">delete</TD></TR></TABLE></TD></TR>',
                  '<TR><TD>interaction for Marcoumar</TD></TR>',
                  '<TR><TD>interaction for Marcoumar</TD></TR></TABLE> <DIV id="drugs"></DIV><TABLE cellspacing="0">',
                  '<TR><TH>&nbsp;</TH></TR>',
                  '<TR><TD class="css.info"></TD></TR>',
                  '<TR><TD class="css.info-bg"></TD></TR></TABLE>',
    ]
    html = composite.to_html(CGI.new)
    expected.each_with_index do |line, idx|
      # puts "#{idx}: missing #{line}" unless html.index(line)
      assert(html.index(line),  "#{idx}: missing #{line} in #{html}")
    end
  end
end
