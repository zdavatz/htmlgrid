#!/usr/bin/env ruby
# encoding: utf-8
# JavaScript -- htmlgrid -- 25.10.2005 -- hwyss@ywesee.com

require 'htmlgrid/component'

module HtmlGrid
	class JavaScript < Component
		def init
			super
			@attributes = {
				'type'		=>	'text/javascript',
				'language'=>	'JavaScript',
			}
		end
		def to_html(context)
			context.script(@attributes) {
				@value.to_s
			}
		end
	end
end
