#!/usr/bin/env ruby
# HtmlGrid::DojoToolkit -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'

module HtmlGrid
	class Component
		attr_accessor :dojo_tooltip
		def dojo_tag(widget, args)
			dojo_tag = "<dojo:#{widget}"
			args.each { |key, value|
				if(value.is_a?(Array))
					dojo_tag << " #{key} = \"#{value.join(';')}\""	
				else
					dojo_tag << " #{key} = \"#{value}\""	
				end
			}
			dojo_tag << " />"
			dojo_tag
		end
		unless(method_defined?(:dojo_dynamic_html))
			alias :dojo_dynamic_html :dynamic_html
			def dynamic_html(context)
				html = dojo_dynamic_html(context)
				if(@dojo_tooltip.is_a?(String))
					attrs = {
						'dojoType'  => 'tooltip',
						'connectId' =>	css_id,
						'href'			=>	@dojo_tooltip,
					}
					html << context.a(attrs)
				end
				html
			end
		end
	end
	module DojoToolkit
		module DojoTemplate
			DOJO_WIDGETS = []
			def dynamic_html_headers(context) 
				headers = super
				args = {
					'language'	=> 'JavaScript',
					'type'			=>	'text/javascript',
					'src'				=>	@lookandfeel.resource_global(:dojo_js),
				}
				headers << context.script(args)
				args = {
					'language'	=> 'JavaScript',
					'type'			=>	'text/javascript',
				}
				widgets = []
				self.class::DOJO_WIDGETS.each { |widget_name|
					widgets.push("dojo.require('dojo.widget.#{widget_name}');")
				}
				headers << context.script(args) {widgets.join}
			end
		end
	end
end
