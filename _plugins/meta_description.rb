require 'json'
require 'sanitize'
module Jekyll
  class MetaDescription < Liquid::Tag
    def render(context)
      if context['page'].has_key? 'description'
        @description = context['page']['description']
      else
        @description = context['page']['excerpt']
      end
      @description = JSON.generate(Sanitize.clean(@description),quirks_mode: true)
      "<meta property='og:description' content=#{@description}/>"+
      "<meta name='description' content=#{@description}/>"
    end
  end
end

Liquid::Template.register_tag 'MetaDescription', Jekyll::MetaDescription