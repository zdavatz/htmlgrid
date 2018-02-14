#!/usr/bin/env ruby
# encoding: utf-8
# HtmlGrid::DojoToolkit -- davaz.com -- 06.04.2012 -- yasaka@ywesee.com
# HtmlGrid::DojoToolkit -- davaz.com -- 14.03.2006 -- mhuggler@ywesee.com

require 'htmlgrid/component'
require 'htmlgrid/div'
require 'htmlgrid/template'

module HtmlGrid
  class Component
    @@msie_ptrn = /MSIE\s*(\d)/
    attr_accessor :dojo_tooltip
    def dojo_tag(widget, args={}, inner_html='')
      div = HtmlGrid::Div.new(@model, @session, self)
      div.set_attribute('data-dojo-type', widget)
      args.each { |key, value|
        if value.is_a?(Array)
          value = value.join(',')
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
    def dojo_parse_on_load
      if @container.respond_to?(:dojo_parse_on_load)
        @container.dojo_parse_on_load
      end
    end
    unless method_defined?(:dojo_dynamic_html)
      alias :dojo_dynamic_html :dynamic_html
      def dynamic_html(context)
        html = ''
        attrs = {
          'data-dojo-type'  => 'dijit/TooltipDialog',
          'data-dojo-props' => "connectId:#{css_id}",
          'id'              => "#{css_id}_widget",
          'style'           => 'display: none',
        }
        unless (match = @@msie_ptrn.match(@session.user_agent)) \
               && match[1].to_i < 7
          attrs.update({
            'toggle'         => 'fade',
            'toggleDuration' => '500',
          })
        end
        @dojo_tooltip ||= nil
        if @dojo_tooltip.is_a?(String)
          if @dojo_tooltip !~ /^http/ # e.g. javascript
            attrs.store('href', "#@dojo_tooltip")
          else
            attrs.store('href', @dojo_tooltip)
          end
          html << context.div(attrs)
        elsif @dojo_tooltip.respond_to?(:to_html)
          @dojo_tooltip.attributes.update(attrs)
          html << @dojo_tooltip.to_html(context).force_encoding('utf-8')
        end
        unless html.empty? || dojo_parse_on_load
          html << context.script('type' => 'text/javascript') { "dojoConfig.searchIds.push('#{css_id}')" }
        end
        # call original dynamic_html
        dojo_dynamic_html(context) << html
      end
    end
  end
	module DojoToolkit
		module DojoTemplate
			DOJO_DEBUG = true
			DOJO_BACK_BUTTON = false
      DOJO_ENCODING = nil
      DOJO_PARSE_ON_LOAD = true
			DOJO_PREFIX = []
			DOJO_REQUIRE = []
      def dynamic_html_headers(context)
        headers = super
        encoding = self.class::DOJO_ENCODING
        encoding ||= Encoding.default_external
        dojo_path = @lookandfeel.resource_global(:dojo_js)
        dojo_path ||= '/resources/dojo/dojo/dojo.js'
        args = { 'type' => 'text/javascript'}
        packages = ""
        unless(self.class::DOJO_PREFIX.empty?)
          packages = self.class::DOJO_PREFIX.collect { |prefix, path|
            "{ name: '#{prefix}', location: '#{path}' }"
          }.join(",")
        end
        puts "dynamic_html_headers with pkgs: #{packages}"
        config =config = [
          "has: {
             'dojo-debug-messages': true
          }",
        ].join(',')
        headers << %(<script>
       var dojoConfig = {
            parseOnLoad: true,
            isDebug: true,
            async: true,
            urchin: '',
        };
</script>)
        headers << context.script(args)
        {  'text/css'         => File.join(File.dirname(dojo_path), "/resources/dojo.css"),
           'text/javascript'  => dojo_path,
        }.each do |type, path|
          if (content = get_inline(path))
            headers << context.style(:type =>type) { content }
          else
            headers << context.style(:type =>type, :src => path) { "@import \"#{path}\";" }
          end
        end
        headers
      end
      def dojo_parse_on_load
        self.class::DOJO_PARSE_ON_LOAD
      end
			def onload=(script)
				(@dojo_onloads ||= []).push(script)
			end
		end
	end
end
