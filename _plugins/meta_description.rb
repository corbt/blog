require 'json'
module Jekyll
  class MetaDescription < Liquid::Tag
    def render(context)
      if context['page'].has_key? 'description'
        @description = context['page']['description']
      else
        @description = context['page']['content'].split('.').first+"."
      end

      "<meta property='og:description' content=#{JSON.generate(@description,quirks_mode: true)}/>"
    end
  end
end

Liquid::Template.register_tag 'MetaDescription', Jekyll::MetaDescription