#!/usr/bin/env ruby
# encoding: utf-8
# HtmlGrid::DojoToolkit -- davaz.com -- 06.04.2012 -- yasaka@ywesee.com
# HtmlGrid::DojoToolkit -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/div'

module HtmlGrid
	class Component
    @@msie_ptrn = /MSIE\s*(\d)/
		attr_accessor :dojo_tooltip
    # FIXME
    # DOJO_VERSION >= 1.7.0 only (removed old version support)
		def dojo_tag(widget, args={}, inner_html='')
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
      lim = ","
      args.each { |key, value|
        if(value.is_a?(Array))
          value = value.join(lim)
        end
        div.set_attribute(key, value)
      }
      div.value = inner_html
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
          'data-dojo-type' =>  'ywesee.widget.Tooltip',
          'connectId'      =>  css_id,
          'id'             =>  "#{css_id}_widget",
          'style'          =>  'display: none',
        }
        unless((match = @@msie_ptrn.match(@session.user_agent)) \
               && match[1].to_i < 7)
          attrs.update({
            'toggle'         => 'fade',
            'toggleDuration' => '500',
          })
        end
        if(@dojo_tooltip.is_a?(String))
          attrs.store('href', "'#@dojo_tooltip'")
          html << context.div(attrs)
        elsif(@dojo_tooltip.respond_to?(:to_html))
          @dojo_tooltip.attributes.update(attrs)
          html << @dojo_tooltip.to_html(context).force_encoding('utf-8')
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
      DOJO_ENCODING = nil
			DOJO_PARSE_WIDGETS = true
			DOJO_PREFIX = []
			DOJO_REQUIRE = []
      def dynamic_html_headers(context)
        headers = super
        encoding = self.class::DOJO_ENCODING
        encoding ||= Encoding.default_external
        dojo_path = @lookandfeel.resource_global(:dojo_js)
        dojo_path ||= '/resources/dojo/dojo/dojo.js'
        args = { 'type' => 'text/javascript'}
        headers << context.script(args.dup) {
          "djConfig = {
            isDebug:              #{self.class::DOJO_DEBUG},
            parseWidgets:         #{dojo_parse_widgets},
            preventBackButtonFix: #{!self.class::DOJO_BACK_BUTTON},
            bindEncoding:         '#{encoding}',
            searchIds:            [],
            urchin:               ''
          };"
        }
        packages = ""
        unless(self.class::DOJO_PREFIX.empty?)
          packages = self.class::DOJO_PREFIX.collect { |prefix, path|
            "{ name: '#{prefix}', location: '#{path}' }"
          }.join(",")
        end
        config = [
          "parseOnLoad:          true",
          "isDebug:              #{self.class::DOJO_DEBUG}",
          "preventBackButtonFix: #{!self.class::DOJO_BACK_BUTTON}",
          "bindEncoding:         '#{encoding}'",
          "searchIds:            []",
          "async:                true",
          "urchin:               ''",
          "has: {
             'dojo-firebug':        #{self.class::DOJO_DEBUG},
             'dojo-debug-messages': #{self.class::DOJO_DEBUG}
          }",
          "packages: [ #{packages} ]"
        ].join(',')
        args.store('data-dojo-config', config)
        args.store('src', dojo_path)

        headers << context.script(args)
        args = { 'type' => 'text/javascript' }
        headers << context.script(args) {
          script = ''
          self.class::DOJO_REQUIRE.each { |req|
            script << "'#{req}',"
          }
          if(@dojo_onloads)
            onloads = ''
            @dojo_onloads.each { |onload|
              onloads << "#{onload}\n"
            }
            script =
            "require([#{script.chomp(',')}], function(ready, parser) {" \
              "ready(function() {" \
                "#{onloads}" \
              "});" \
            "});"
          else
            script = "require([#{script.chomp(',')}]);"
          end
          script
        }
        dojo_dir = File.dirname(dojo_path)
        headers << context.style(:type => "text/css") { <<-EOS
            @import "#{File.join(dojo_dir, "/resources/dojo.css")}";
            @import "#{File.join(dojo_dir, "../dijit/themes/tundra/tundra.css")}";
          EOS
        }
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
