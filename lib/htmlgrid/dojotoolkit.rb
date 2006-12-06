#!/usr/bin/env ruby
# HtmlGrid::DojoToolkit -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'

module HtmlGrid
	class Component
		attr_accessor :dojo_tooltip
		def dojo_tag(widget, args={})
			# <dojo:#{widget} ...> does not work on konqueror as of 
			# 02.06.2006. In combination with DOJO_DEBUG = true it even 
			# hangs konqueror.
			dojo_tag = "<div dojoType=\"#{widget}\""
			args.each { |key, value|
				if(value.is_a?(Array))
					dojo_tag << " #{key}=\"#{value.join(';')}\""	
				else
					dojo_tag << " #{key}=\"#{value}\""	
				end
			}
			dojo_tag << "></div>"
		end
    def dojo_title=(value)
      tooltip = HtmlGrid::Div.new(@model, @session, self)
      tooltip.value = value
      self.dojo_tooltip = tooltip
    end
		def dojo_parse_widgets
			if(@container.respond_to?(:dojo_parse_widgets))
				@container.dojo_parse_widgets
			end
		end
		unless(method_defined?(:dojo_dynamic_html))
			alias :dojo_dynamic_html :dynamic_html
			def dynamic_html(context)
				html = ''
				if(@dojo_tooltip.is_a?(String))
					attrs = {
						'dojoType'  => 'tooltip',
						'connectId' =>	css_id,
						'href'			=>	@dojo_tooltip,
						'toggle'		=>	'fade',
						'toggleDuration'	=>	'500',
						'style'			=>	'display: none',
					}
					html << context.a(attrs)
				elsif(@dojo_tooltip.respond_to?(:to_html))
					@dojo_tooltip.attributes.update({
						'dojoType'  => 'tooltip',
						'connectId' =>	css_id,
						'toggle'		=>	'fade',
						'toggleDuration'	=>	'500',
						'style'			=>	'display: none',
					})
					html << @dojo_tooltip.to_html(context)
				end
				unless(html.empty? || dojo_parse_widgets)
					html << context.script('type' => 'text/javascript') {
						"djConfig.searchIds.push('#{css_id}')"
					}
				end
				dojo_dynamic_html(context) << html
			end
		end
	end
	module DojoToolkit
		module DojoTemplate
			DOJO_DEBUG = false
			DOJO_BACK_BUTTON = false
			DOJO_PARSE_WIDGETS = true
			DOJO_PREFIX = []
			DOJO_REQUIRE = []
			def dynamic_html_headers(context) 
				headers = super
				args = {
					'type'			=>	'text/javascript',
				}	
        encoding = $KCODE == 'UTF8' ? 'UTF-8' : 'ISO-8859-1'
				headers << context.script(args) { 
					"djConfig = { 
						isDebug: #{self.class::DOJO_DEBUG}, 
						parseWidgets: #{dojo_parse_widgets},
						preventBackButtonFix: #{!self.class::DOJO_BACK_BUTTON},
            bindEncoding: '#{encoding}',
						searchIds: []
					};" 
				}
				dojo_path = @lookandfeel.resource_global(:dojo_js) \
					|| '/resources/dojo/dojo.js'
				args = {
					'type'			=>	'text/javascript',
					'src'				=>	dojo_path,
				}
				headers << context.script(args)
				unless(self.class::DOJO_PREFIX.empty?)
					args = {
						'type'			=>	'text/javascript',
					}	
					headers << context.script(args) { 
						self.class::DOJO_PREFIX.collect { |prefix, path|
							"dojo.setModulePrefix('#{prefix}', '#{path}');"
						}.join
					}
				end
				args = {
					'type'			=>	'text/javascript',
				}
				headers << context.script(args) {
					script = ''
					self.class::DOJO_REQUIRE.each { |req|
						script << "dojo.require('#{req}');"
					}
					if(@dojo_onloads)
						@dojo_onloads.each { |onload|
							script << "dojo.addOnLoad(function() { #{onload} });"
						}
					end
					script
				}
			end
			def dojo_parse_widgets
				self.class::DOJO_PARSE_WIDGETS
			end
			def onload=(script)
				(@dojo_onloads ||= []).push(script)
			end
		end
	end
end
