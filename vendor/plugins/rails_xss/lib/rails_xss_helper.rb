# Overwrites helper methods in Action Pack to give them Rails XSS powers. These powers are there by default in Rails 3.
module RailsXssHelper
  def link_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      concat(link_to(capture(&block), options, html_options))
    else
      name         = args.first
      options      = args.second || {}
      html_options = args.third

      url = url_for(options)

      if html_options
        html_options = html_options.stringify_keys
        href = html_options['href']
        convert_options_to_javascript!(html_options, url)
        tag_options = tag_options(html_options)
      else
        tag_options = nil
      end

      href_attr = "href=\"#{url}\"" unless href
      "<a #{href_attr}#{tag_options}>#{ERB::Util.h(name || url)}</a>".html_safe
    end
  end
end

ActionController::Base.helper(RailsXssHelper)

module ActionView
  module Helpers
    module TagHelper
      private
        def content_tag_string_with_escaping(name, content, options, escape = true)
          content_tag_string_without_escaping(name, ERB::Util.h(content), options, escape)
        end
        alias_method_chain :content_tag_string, :escaping
    end

    module TextHelper
      def simple_format_with_escaping(text, html_options={})
        simple_format_without_escaping(ERB::Util.h(text), html_options)
      end
      alias_method_chain :simple_format, :escaping
    end
  end
end
