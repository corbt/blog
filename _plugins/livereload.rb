module Jekyll
  class LiveReload < Liquid::Tag
    def render(context)
      '<script src="http://localhost:35729/livereload.js"></script>' unless ENV['JEKYLL_ENV'] == 'production'
    end
  end
end

Liquid::Template.register_tag 'LiveReload', Jekyll::LiveReload