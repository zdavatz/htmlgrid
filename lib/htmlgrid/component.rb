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
# Component -- htmlgrid -- 23.10.2002 -- hwyss@ywesee.com 

module HtmlGrid
	class Component
		CSS_CLASS = nil
		HTML_ATTRIBUTES = {}
		HTTP_HEADERS = {}
		LABEL = false
		@@html_entities = [
			['&', 'amp'],
			['<', 'lt'],
			['>', 'gt'],
		]
		@@symbol_entities = {
			34	=>	"forall",
			36	=>	"exist",
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
	                           	163	=>	"le",
															165	=>	"infin",
															166	=>	"int",
															179	=>	"ge",
															182	=>	"part",
															185	=>	"ne",
															186	=>	"equiv",
															187	=>	"asymp",
															199	=>	"cap",
															200	=>	"cup",
															201	=>	"sup",
															202	=>	"supe",
															203	=>	"nsub",
															204	=>	"sub",
															205	=>	"sube",
															206	=>	"isin",
															207	=>	"notin",
															213	=>	"prod",
															214	=>	"radic",
															229	=>	"sum",
		}
		attr_reader :attributes, :model
		attr_accessor :value
		def initialize(model, session=nil, container=nil)
			#puts "initializing #{self.class}"
			@model = model
			@session = session
			@lookandfeel = session.lookandfeel if session.respond_to?(:lookandfeel)
			@container = container
			@attributes = self::class::HTML_ATTRIBUTES.dup
			if(css_class())
				@attributes.store("class", css_class())
			end
			@value = nil
			@label = self::class::LABEL
			init()
			#puts "#{self.class} initialized"
		end
		def css_class
			@css_class ||= self::class::CSS_CLASS
		end
		def css_class=(css_class)
			@css_class = @attributes['class'] = css_class
		end
		def escape(txt)
			@@html_entities.inject(txt.to_s.dup) { |str, map| 
				char, entity = map
				str.gsub!(char, '&' << entity << ';')
				str
			}
		end
		def escape_symbols(txt)
			esc = ''
			txt.to_s.each_byte { |byte|
				esc << if(entity = @@symbol_entities[byte])
					'&' << entity << ';'
				else
					byte.chr
				end
			}
			esc
		end
		def formname
			@container.formname if @container.respond_to?(:formname)
		end
		def http_headers
			self::class::HTTP_HEADERS
		end
		def label?
			@label
		end
		def label=(boolean)
			@label = boolean
		end
		def onload=(onload)
			@container.onload = onload if(@container.respond_to? :onload=)
		end
		def onsubmit=(onsubmit)
			@container.onsubmit = onsubmit if(@container.respond_to? :onsubmit=)
		end
		def set_attribute(key, value)
			@attributes.store(key, value)
		end
		def tabindex=(tab)
			@attributes.store('tabindex', tab.to_s)
		end
		def to_html(context)
			@value.to_s.gsub(/(\n)|(\r)|(\r\n)/, '<br>')
		end
		private
		def init
		end
	end
end
