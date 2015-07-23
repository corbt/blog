require 'rubygems'
require 'optparse'
require 'yaml'
require 'guard'

desc "create new post"
task :np do
  OptionParser.new.parse!
  ARGV.shift
  title = ARGV.join(' ')

  title_slug = "#{Date.today}-"+title.downcase.gsub(/[^[:alnum:]\s]+/, '').gsub(/\s+/, '-')
  path = "_posts/#{title_slug}.md"
  
  if File.exist?(path)
    puts "[WARN] File exists - skipping create"
  else
    File.open(path, "w") do |file|
      file.puts YAML.dump({'layout' => 'post', 'published' => true, 'title' => title, 'comments' => true})
      file.puts "---"
    end
  end
  exit 1
end

desc "serve files"
task :serve do
  `guard`
end

config_file = '_config.yml'
config = YAML.load_file(config_file)

env = ENV['env'] || 'prod'

desc "update the blog"
task :push do
  command = "JEKYLL_ENV=production jekyll build && rsync -avz "
  unless config['environments'][env]['remote']['port'].nil?
    command << "-e 'ssh -p #{config['environments'][env]['remote']['port']}' "
  end
  command << "./#{config['destination']}/ #{config['environments'][env]['remote']['connection']}:#{config['environments'][env]['remote']['path']}"
  sh command
end
