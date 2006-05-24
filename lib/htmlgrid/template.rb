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
# Template -- htmlgrid -- 19.11.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'

module HtmlGrid
	module TemplateMethods
		CONTENT = nil
		FOOT = nil
		HEAD = nil
		HTTP_HEADERS = {
			"Cache-Control"	=>	"no-cache, max-age=3600, must-revalidate",
		}
		META_TAGS = []
		LEGACY_INTERFACE = true
		CSS_FILES = []
		JAVASCRIPTS = []
		def css_link(context, path=@lookandfeel.resource(:css))
			properties = {
				"rel"		=>	"stylesheet",
				"type"	=>	"text/css",
				"href"	=>	path,
			}
			context.link(properties)
		end
		def css_links(context, path=@lookandfeel.resource(:css))
			links = self.class.const_get(:CSS_FILES).collect { |key| 
				css_link(context, @lookandfeel.resource(key)) 
			}
			links.push(css_link(context, path)) if(path)
			links.join
		end
		def content(model, session=nil)
			__standard_component(model, self::class::CONTENT)
		end
		def dynamic_html_headers(context)
			''
		end
		def foot(model, session=nil)
			__standard_component(model, self::class::FOOT)
		end
		def head(model, session=nil)
			__standard_component(model, self::class::HEAD)
		end
		def __standard_component(model, klass)
			if(klass.is_a?(Class))
				klass.new(model, @session, self)
			end
		end
		def html_head(context, &block)
			context.head {
				if(block_given?)
					block.call
				end.to_s <<
				title(context) << 
				css_links(context) <<
				meta_tags(context) <<
				other_html_headers(context) <<
				javascripts(context)
			}
		end
		def javascripts(context)
			jscripts = self.class.const_get(:JAVASCRIPTS).collect { |key|
				properties = {
					"language"	=>	"JavaScript",
					"type"			=>	"text/javascript",
					"src"				=>	@lookandfeel.resource_global(:javascript, "#{key}.js"),
				}		
				context.script(properties)
			}
			jscripts.join
		end
		def meta_tags(context)
			self::class::META_TAGS.inject('') { |inj, properties|
				inj << context.meta(properties)
			}
		end
		def onload=(script)
			@attributes['onload'] = script
		end
		def other_html_headers(context)
			dynamic_html_headers(context)
		end
		def template_html(context, &block)
			args = {}
			if(dtd = @lookandfeel.lookup(:DOCTYPE))
				args.store('DOCTYPE', dtd)
			end
			context.html(args) {
				html_head(context) << context.body(@attributes) {
					template_tags(context, &block)
				}
			}
		end
		def template_tags(context, &block)
			block.call
		end
		def title(context)
			context.title { @lookandfeel.lookup(:html_title) }
		end
		def to_html(context)
			template_html(context) {
				super(context)
			}
		end
	end
	class Template < Composite
		include TemplateMethods
	end
end
