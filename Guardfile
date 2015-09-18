require 'rubygems'
require 'bundler/setup'

watch ("Guardfile") do
  UI.info "Exiting because Guard must be restarted for changes to take effect"
  exit 0
end

guard 'jekyll-plus', serve: true do
  callback(:start_end) { `open http://localhost:4000` }
  watch /.*/
  ignore /_site/
end

guard 'livereload' do
  watch /.*/
  # watch /_site/
end