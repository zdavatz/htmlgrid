#!/usr/bin/env ruby
# HtmlGrid::DojoToolkit -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/div'

module HtmlGrid
	class Component
		attr_accessor :dojo_tooltip
    def dojo_9?
      defined?(DOJO_VERSION) && DOJO_VERSION >= '0.9'
    end
		def dojo_tag(widget, args={})
			# <dojo:#{widget} ...> does not work on konqueror as of 
			# 02.06.2006. In combination with DOJO_DEBUG = true it even 
			# hangs konqueror.
=begin
			dojo_tag = "<div dojoType=\"#{widget}\""
			args.each { |key, value|
				if(value.is_a?(Array))
					dojo_tag << " #{key}=\"#{value.join(';')}\""	
				else
					dojo_tag << " #{key}=\"#{value}\""	
				end
			}
			dojo_tag << "></div>"
=end
      div = HtmlGrid::Div.new(@model, @session, self)
      div.set_attribute('dojoType', widget)
      lim = dojo_9? ? "," : ";"
      args.each { |key, value|
        if(value.is_a?(Array))
          value = value.join(lim)
        end
        div.set_attribute(key, value)
      }
      div
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
        attrs = {
          'dojoType'  => dojo_9? ? 'ywesee.widget.Tooltip' : 'tooltip',
          'connectId' =>	css_id,
          'id'        =>  "#{css_id}_widget",
          'style'			=>	'display: none',
        }
        unless((match = /MSIE\s*(\d)/.match(@session.user_agent)) \
               && match[1].to_i < 7)
          attrs.update({
						'toggle'		      =>	'fade',
						'toggleDuration'	=>	'500',
          })
        end
				if(@dojo_tooltip.is_a?(String))
          attrs.store('href', @dojo_tooltip)
					html << context.div(attrs)
				elsif(@dojo_tooltip.respond_to?(:to_html))
					@dojo_tooltip.attributes.update(attrs)
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
        encoding = $KCODE == 'UTF8' ? 'UTF-8' : 'ISO-8859-1'
        dojo_path = @lookandfeel.resource_global(:dojo_js)
        args = {
          'type'			=>	'text/javascript',
        }	
        if(dojo_9?)
          dojo_path ||= '/resources/dojo/dojo/dojo.js'
          config = [ "parseOnLoad:true",
                     "isDebug:#{self.class::DOJO_DEBUG}",
                     "preventBackButtonFix:#{!self.class::DOJO_BACK_BUTTON}",
                     "bindEncoding:'#{encoding}'", ].join(',')
          args.store('djConfig', config)
        else
          headers << context.script(args.dup) { 
            "djConfig = { 
              isDebug: #{self.class::DOJO_DEBUG}, 
              parseWidgets: #{dojo_parse_widgets},
              preventBackButtonFix: #{!self.class::DOJO_BACK_BUTTON},
              bindEncoding: '#{encoding}',
              searchIds: []
            };" 
          }
          dojo_path ||= '/resources/dojo/dojo.js'
        end
				args.store('src', dojo_path)
				headers << context.script(args)
				unless(self.class::DOJO_PREFIX.empty?)
          register = dojo_9? ? 'registerModulePath' : 'setModulePrefix'
					args = {
						'type'			=>	'text/javascript',
					}	
					headers << context.script(args) { 
						self.class::DOJO_PREFIX.collect { |prefix, path|
							"dojo.#{register}('#{prefix}', '#{path}');"
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
        if(dojo_9?)
          dojo_dir = File.dirname(dojo_path)
          headers << context.style(:type => "text/css") { <<-EOS
              @import "#{File.join(dojo_dir, "/resources/dojo.css")}";
              @import "#{File.join(dojo_dir, "../dijit/themes/tundra/tundra.css")}";
            EOS
          }
        end
        headers
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
