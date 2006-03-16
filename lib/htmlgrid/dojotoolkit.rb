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
				elsif(@dojo_tooltip.respond_to?(:to_html))
					@dojo_tooltip.attributes.update({
						'dojoType'  => 'tooltip',
						'connectId' =>	css_id,
					})
					html << @dojo_tooltip.to_html(context)
				end
				html
			end
		end
	end
	module DojoToolkit
		module DojoTemplate
			DOJO_REQUIRE = []
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
				requires = []
				self.class::DOJO_REQUIRE.each { |req|
					requires.push("dojo.require('#{req}');")
				}
				headers << context.script(args) {requires.join}
			end
		end
	end
end
