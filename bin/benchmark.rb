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
#	htmlgrid@ywesee.com, www.ywesee.com
#
# Benchmark -- HtmlGrid -- 12.11.2003 -- hwyss@ywesee.com

$: << File.expand_path("../test", File.dirname(__FILE__))

require 'benchmark'
require 'htmlgrid/list'
require 'htmlgrid/link'
require 'stub/cgi'

class StubComponent < HtmlGrid::Component
	def to_html(context)
		"The quick brown fox jumped over the lazy dogs!"
	end
end
class StubInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:foo,	
		[1,0]	=>	:bar,
		[0,1]	=>	StubComponent,
	}
	CSS_MAP = {
		[0,0,2,2]	=>	"css-classy"
	}
	COMPONENT_CSS_MAP = {
		[0,1]	=>	"classy-component"
	}
	def foo(model, session)
		"foo!"
	end
	def bar(model, session)
		"bar?"
	end
end
class StubComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	StubComponent,
		[0,1]	=>	StubInnerComposite,
		[0,2]	=>	:foobar,
	}
	def foobar(model, session)
		[
			"foo!",
			model.to_s,
			"bar!",
			session.to_s,
			"foobar!",
		].join("<br>")
	end
end
class StubList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	StubComposite,
		[1,0]	=>	StubInnerComposite,
		[2,0]	=>	StubComponent,
		[3,0]	=>	:foo,
	}
	def foo(model, session)
		[
			model, 
			"foo",
			model, 
			"bar",
			model,
		].join("-")
	end
end
class StubSession
	attr_accessor :event
	def attributes(*keys)
		keys.inject({}) { |inj, key|
			inj.store(key.to_s, "attribute for #{key}")
			inj
		}
	end
	def event_url(*keys)
		(["http://www.oddb.org"] + keys).join
	end
	def lookandfeel
		self
	end
	def lookup(*keys)
		"looked up #{keys.join(":")}"
	end
	def state
		self
	end
end

model = []
1.upto(1000) { |idx|
	model << idx
}
session = StubSession.new
Benchmark.bmbm { |bm|
	comp = nil
	bm.item("compose") {
		comp = StubList.new(model, session)
	}
	bm.item("to_html") {
		comp.to_html(CGI.new)
	}
}
