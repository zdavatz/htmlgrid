#!/usr/bin/env ruby
# encoding: utf-8
#--
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
# HtmlGrid::Component -- htmlgrid -- 23.12.2012 -- mhatakeyama@ywesee.com 
# HtmlGrid::Component -- htmlgrid -- 23.10.2002 -- hwyss@ywesee.com 
#++

module HtmlGrid
	class Component
		# sets the 'class' html-attribute
		CSS_CLASS = nil
		# sets the 'id' html-attribute
		CSS_ID = nil
		# other html-attributes
		HTML_ATTRIBUTES = {}
    # default http-headers
    HTTP_HEADERS = {
      "Content-Type"  => "text/html",
      "Cache-Control" => "no-cache, max-age=3600, must-revalidate",
    }
		# precede instances of this class with a label?
		LABEL = false
		@@html_entities = [
			['&', 'amp'],
			['<', 'lt'],
			['>', 'gt'],
		] # :nodoc:
		@@symbol_entities = {
			34	=>	"forall",
			36	=>	"exist",
			42	=>	"lowast",
			45	=>	"minus",
			64	=>	"cong",
			65	=>	"Alpha",				97	=>	"alpha",
			66	=>	"Beta",     		98	=>	"beta",
			67	=>	"Chi",      		99	=>	"chi",
			68	=>	"Delta",    		100	=>	"delta",
			69	=>	"Epsilon",  		101	=>	"epsilon",
			70	=>	"Phi",      		102	=>	"phi",
			71	=>	"Gamma",    		103	=>	"gamma",
			72	=>	"Eta",      		104	=>	"eta",
			73	=>	"Iota",     		105	=>	"iota",
			75	=>	"Kappa",    		107	=>	"kappa",
			76	=>	"Lambda",   		108	=>	"lambda",
			77	=>	"Mu",       		109	=>	"mu",
			78	=>	"Nu",       		110	=>	"nu",
			79	=>	"Omicron",  		111	=>	"omicron",
			80	=>	"Pi",       		112	=>	"pi",
			81	=>	"Theta",    		113	=>	"theta",
			82	=>	"Rho",      		114	=>	"rho",
			83	=>	"Sigma",    		115	=>	"sigma",
			84	=>	"Tau",      		116	=>	"tau",
			85	=>	"Upsilon",  		117	=>	"upsilon",
			86	=>	"sigmaf",   		
			87	=>	"Omega",    		119	=>	"omega",
			88	=>	"Xi",       		120	=>	"xi",
			89	=>	"Psi",      		121	=>	"psi",
			90	=>	"Zeta",     		122	=>	"zeta",
			94	=>	"perp",					126	=>	"sim",
	                           	163	=>	"le",
															165	=>	"infin",
															166	=>	"fnof",
															171	=>	"harr",
															172	=>	"larr",
															173	=>	"uarr",
															174	=>	"rarr",
															175	=>	"darr",
															179	=>	"ge",
															181	=>	"prop",
															182	=>	"part",
															185	=>	"ne",
															186	=>	"equiv",
															187	=>	"asymp",
															191	=>	"crarr",
															196	=>	"otimes",
															197	=>	"oplus",
															198	=>	"empty",
															199	=>	"cap",
															200	=>	"cup",
															201	=>	"sup",
															202	=>	"supe",
															203	=>	"nsub",
															204	=>	"sub",
															205	=>	"sube",
															206	=>	"isin",
															207	=>	"notin",
															208	=>	"ang",
															209	=>	"nabla",
															213	=>	"prod",
															214	=>	"radic",
															215	=>	"sdot",
															217	=>	"and",
															218	=>	"or",
															219	=>	"hArr",
															220	=>	"lArr",
															221	=>	"uArr",
															222	=>	"rArr",
															223	=>	"dArr",
															229	=>	"sum",
															242	=>	"int",
		} # :nodoc:
		attr_reader :attributes, :model
		attr_accessor :value
		def initialize(model, session=nil, container=nil)
			@model = model
			@session = session
			@lookandfeel = session.lookandfeel if session.respond_to?(:lookandfeel)
			@container = container
			@attributes = self::class::HTML_ATTRIBUTES.dup
			if(css_class())
				@attributes.store("class", css_class())
			end
			if(css_id())
				@attributes.store("id", css_id())
			end
			@value = nil
			@label = self::class::LABEL
			init()
		end
		# delegator to @container, default definition in Form
		def autofill?
			@container.autofill? if @container.respond_to?(:autofill?)
		end
		# gets the 'class' html-attribute if defined
		def css_class
			@css_class ||= self::class::CSS_CLASS
		end
		# sets the 'class' html-attribute
		def css_class=(css_class)
			@css_class = @attributes['class'] = css_class
		end
		# gets the 'id' html-attribute if defined
		def css_id
			@css_id ||= self::class::CSS_ID
		end
		# sets the 'id' html-attribute
		def css_id=(css_id)
			@css_id = @attributes['id'] = css_id
		end
		def dynamic_html(context)
			''
		end
		# escape '&', '<' and '>' characters in txt
		def escape(txt)
			@@html_entities.inject(txt.to_s.dup) { |str, map| 
				char, entity = map
				str.gsub!(char, '&' << entity << ';')
				str
			}
		end
		# escape symbol-font strings
		def escape_symbols(txt)
			esc = ''
			txt.to_s.each_byte { |byte|
				esc << if(entity = @@symbol_entities[byte])
					'&' << entity << ';'
				else
          byte
				end
			}
			esc
		end
		# delegator to @container, default definition in Form
		def formname
			@container.formname if @container.respond_to?(:formname)
		end
		def http_headers
			self::class::HTTP_HEADERS.dup
		end
		# precede this instance with a label?
		def label?
			@label
		end
		def label=(boolean)
			@label = boolean
		end
		def onclick=(onclick)
      @attributes['onclick'] = onclick
		end
		# delegator to @container, default definition in Template
		def onload=(onload)
			@container.onload = onload if(@container.respond_to? :onload=)
		end
		# delegator to @container, default definition in Form
		def onsubmit=(onsubmit)
			@container.onsubmit = onsubmit if(@container.respond_to? :onsubmit=)
		end
		# set a html attribute
		def set_attribute(key, value)
			@attributes.store(key, value)
		end
		def tabindex=(tab)
			@attributes.store('tabIndex', tab.to_s)
		end
    def to_html(context)
      _to_html(context, @value).to_s.force_encoding('utf-8')
    end
    @@nl2br_ptrn = /(\r\n)|(\n)|(\r)/
		def _to_html(context, value=@value)
			if(value.is_a?(Array))
				value.collect { |item| _to_html(context, item) }.join(' ')
			elsif(value.respond_to?(:to_html))
				value.to_html(context).to_s.force_encoding('utf-8')
			else
				value.to_s.gsub(@@nl2br_ptrn, '<br>')
			end
		end
		private
		def init
		end
	end
end
