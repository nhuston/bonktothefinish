###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

set :markdown_engine, :kramdown
set :markdown, parse_block_html: true
activate :syntax, :line_numbers => true

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

# Reload the browser automatically whenever files change
configure :development do
  config[:host] = "localhost:4567"
  config[:repo_src] = "https://github.com/nhuston/bonktothefinish"
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
  deploy.remote   = 'https://github.com/nhuston/nhuston.github.io.git' #I recommend a URL over a 'remote' name, as those have broken on me
  deploy.branch = 'master'
  deploy.build_before = true
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
   def get_article_img(article_tags)
     tag_links = data.tags.tag_images
     #search thru data's tag list, return image url of first tag found
     for tag in tag_links do
       if article_tags.include? tag.name then
         return tag.url
       end
     end

     #return last tag's image url
     return tag_links[tag_links.length-1].url
   end

  def img_link(img_url, img_alt, url, title, css_class,target = "_blank",id="")
    img = app.image_tag img_url, alt: img_alt
    link = app.link_to img, url, title: title,target: target, class: css_class, id: id
  end
 end

# Build-specific configuration
configure :build do
  config[:host] = "http://bonktothefinish.com"
  config[:repo_src] = "https://github.com/nhuston/bonktothefinish"

  # Minify CSS and JS on build
  activate :minify_css
  activate :minify_javascript

  activate :relative_assets
  set :relative_links, true
end
