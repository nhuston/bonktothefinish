###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

# Reload the browser automatically whenever files change
configure :development do
  config[:host] = "localhost:4567"
  activate :livereload
end

activate :blog do |blog|
 # Matcher for blog source files
 # blog.taglink = "tags/{tag}.html"
 blog.layout = "layouts/blog_layout"
 # blog.summary_separator = /(READMORE)/
 blog.summary_length = 150
 # blog.year_link = "{year}.html"
 # blog.month_link = "{year}/{month}.html"
 # blog.day_link = "{year}/{month}/{day}.html"

 blog.tag_template = "tag.html"
 blog.calendar_template = "calendar.html"

 #set up blog urls - needs an '.html' on the end or GitHub will download the link instead of opening in browser
 blog.prefix = "blog"# This will add a prefix to all links, template references and source paths
 blog.permalink = "{title}.html" #"{year}/{month}/{day}/{title}.html"
 blog.sources = "{year}-{month}-{day}-{title}.html" # define year-month-day in filename to make an organized dir
 blog.default_extension = ".markdown"

 # Enable pagination
 blog.paginate = true
 blog.per_page = 10
 blog.page_link = "#{blog.prefix}/page/{num}"
end

# Documentation - https://github.com/middleman-contrib/middleman-deploy
activate :deploy do |deploy|
  deploy.user = 'JTronLabs'
  deploy.deploy_method = :git
  deploy.remote   = 'https://github.com/JTronLabs/JTronLabs.github.io.git' #I recommend a URL over a 'remote' name, as those have broken on me
  deploy.branch = 'master'
  deploy.build_before = true
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Build-specific configuration
configure :build do
  config[:host] = "http://bonktothefinish.com"

  # Minify CSS and JS on build
  activate :minify_css
  activate :minify_javascript

  activate :relative_assets
  set :relative_links, true
end
