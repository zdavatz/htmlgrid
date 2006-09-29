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
# Form -- htmlgrid -- 23.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/submit'

module HtmlGrid
	module FormMethods
		AUTOFILL = false
		ACCEPT_CHARSET = $KCODE == 'UTF8' ? 'UTF-8' : 'ISO-8859-1'
		EVENT = nil
		FORM_ACTION = nil
		FORM_METHOD = 'POST'
		FORM_NAME = 'stdform'
		TAG_METHOD	= :form
		def autofill?
			self.class.const_get(:AUTOFILL)
		end
		def event
			self::class::EVENT
		end
		def formname
			if(defined? self::class::FORM_NAME)
				self::class::FORM_NAME 
			end
		end
		def onsubmit=(onsubmit)
			@form_properties["onSubmit"] = onsubmit
		end
		def to_html(context)
			context.send(self::class::TAG_METHOD, @form_properties) {
				super << context.span { hidden_fields(context) }
			}
		end
		private
		def hidden_fields(context)
			'' << 
			context.hidden('flavor', @lookandfeel.flavor) << 
			context.hidden('language', @lookandfeel.language) << 
			context.hidden({'NAME' => 'event', 'ID' => 'event', 
				'VALUE' => event.to_s}) << 
			context.hidden('state_id', @session.state.object_id.to_s)
		end
		def init
			@form_properties = {}
			if(defined? self::class::FORM_CSS_CLASS)
				@form_properties.store('class', self::class::FORM_CSS_CLASS)
			end
			if(defined? self::class::FORM_NAME)
				@form_properties.store('NAME', self::class::FORM_NAME)
			end
			if(defined? self::class::FORM_ID)
				@form_properties.store('ID', self::class::FORM_ID)
			end
			super
			@form_properties.update({
				'METHOD'					=>	self::class::FORM_METHOD.dup,
				'ACTION'					=>	(self::class::FORM_ACTION || @lookandfeel.base_url),
				'ACCEPT-CHARSET'	=>	self::class::ACCEPT_CHARSET,
			})
		end
	end
	class Form < Composite
		include FormMethods
	end
end
