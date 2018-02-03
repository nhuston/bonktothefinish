#Set to TRUE if you want the links to be checked
check_links_after_build=false




###
# Page options, layouts, aliases and proxies
###
require 'html-proofer'

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

config[:host] = "https://bonktothefinish.com"
config[:site_description] = "BonkToTheFinish.com, home of ultra runner Nicole Huston. Race and fitness discounts, race reports, training info, and stories of acheivement."
set :url_root, config[:host]
set :markdown_engine, :kramdown
set :markdown, parse_block_html: true
activate :syntax, :line_numbers => true
activate :emojifire
activate :search_engine_sitemap
activate :autoprefixer

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

# Reload the browser automatically whenever files change
configure :development do
  config[:host] = "http://localhost:4567"
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
 blog.month_link = "{year}/{month}.html"
 blog.generate_day_pages = false
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
 blog.per_page = 20
 blog.page_link = "#{blog.prefix}/page/{num}"
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do
  #get a "summary" image for the article
  def get_article_img_src(article)
    src = nil

    #first choice: the manually defined image
    if article.data.has_key?(:top_img)
      src = prefix_img(article.data.top_img,article)

    #second choice: first image that appears in the article's body
    else
      doc = Nokogiri::HTML(article.body)
      img = doc.xpath('//img').first
      src = img['src'] if img != nil
    end

    #last choice: get a general icon if a more specific one doesn't exist
    if src == nil
      tag_info = get_tag_info(article.tags)
      if tag_info.key?(:img_url)
        src = tag_info.img_url
      else
        src = tag_info.icon_url
      end
    end
    return src
  end

  def tab_groupings()
    #create an article grouping for each data.tags
    article_groups = {}
    data.tags.each do |tag_info|
      article_groups[tag_info.name] = {
        info: tag_info,
        articles: []
      }
    end

    #add the relevant articles
    max_num_of_tagged_articles = 5
    blog.articles.each do |article|
      tag_info = get_tag_info(article.tags)

      #add articles to article groups, ensure that the groups are under a set # of articles
      if article_groups[tag_info.name][:articles].length < max_num_of_tagged_articles
        article_groups[tag_info.name][:articles].push(article)
      end
    end


    tabs = []
    article_groups.each do |name,value|
      tabs.push({
          'title':name.titleize,
          'articles': value[:articles]
      })
    end
    return tabs
  end

  def tab_id(title)
    return "tab_#{title}"
  end

   def prefix_img(img_name_or_url, page=current_page)
     #strip '.html' extension off article link to get name of folder
     url = page.url
     url_without_ext = url[0..url.length-6]

     #determine if video has an exact link or belongs to "/images/blog/CURRENT_ARTICLE_NAME/"
     if img_name_or_url[0..6] != "http://" and img_name_or_url[0..6] != "https:/" and img_name_or_url[0] !="/" then
       #image belongs to "/images/blog/CURRENT_ARTICLE_NAME/" - add prefix to src
       src = "#{config[:host]}/images#{url_without_ext}/#{img_name_or_url}"
     else
       src = img_name_or_url
     end

     return src
   end

  def word_cloud(words)
    #preprocess to number of occurrences
    occurrences = {}
    words.each do |word, val|
      if not val.is_a? Numeric then
        occurrences[word] = val.length
      else
        occurrences[word] = val
      end
    end

    word = occurrences.keys()[0]
    max_freq = occurrences[word]
    occurrences.each do |word, freq|
      if freq > max_freq then
        max_freq = freq
      end
    end
    max_freq = max_freq.to_f

    ##delete words under the min occurrences
    occurrences.delete_if do |word, freq|
      if freq <= 2
        true # Make sure the if statement returns true, so it gets marked for deletion
      end
    end

    occurrences.each do |word, freq|
      occurrences[word] = occurrences[word] / max_freq
    end

    return occurrences
  end

   def to_mi(str)
     str = str.downcase
      if str == "marathon"
        return 26.2
      elsif str == "half marathon"
        return 13.1
      elsif str == "quarter marathon"
        return 6.55
      elsif str == "ultramarathon"
        return 30
      end

     number = str.scan(/\d+/).first
     if number == nil
       return nil
     end

     unit_start_idx = number.length + str.index(number)
     unit = str[unit_start_idx..-1].downcase
     mi = nil
     if unit == " mile" or unit == " miles"
       mi = number.to_f
     elsif unit =="k"
       mi = number.to_f / 1.60934
     end
     return mi
   end

   def tags_to_mi(tags)
     tags.each do |tag|
       mi = to_mi(tag)
       if mi != nil
         return mi
       end
     end
     return nil
   end

   def get_tag_info(article_tags)
    # distances are top priority
    mi = tags_to_mi(article_tags)
    if mi != nil
      data.tags.each do |tag_info|
        if tag_info.key?(:dist) and mi >= tag_info.dist.low and (not tag_info.dist.key?(:high) or mi < tag_info.dist.high)
          return tag_info
        end
      end
    end

    #article does not have a distance, check the 'tags' property instead
    data.tags.each do |tag_info|
     next if not tag_info.key?(:tags)

     tags = tag_info.tags.split(',')
     tags.each do |tag_name|
       if article_tags.include? tag_name
         return tag_info
       end
     end
    end

    return data.tags.last #default is the last item - "other"/"misc"
   end

   def graph_id(race)
     return race.sub(".","").sub(" ","_")
   end

  def img_link(img_url, img_alt, url, title, css_class,target = "_blank",id="")
    img = app.image_tag img_url, alt: img_alt
    link = app.link_to img, url, title: title,target: target, class: css_class, id: id
  end

  def processed_races_info()
    # pre-parse data.races_info times
    new_info = data.races_info.deep_dup()
    new_info.each do |race_type|
      distance = race_type[0]
      info = race_type[1]
      #sort races by date
      info.each do |race|
        race[:time] = ChronicDuration.parse(race[:time],:keep_zero => true)
      end
      info.sort_by! do |race|
        race[:date]
      end
    end
    return new_info
  end
 end

# Build-specific configuration
configure :build do
  config[:repo_src] = "https://github.com/nhuston/bonktothefinish"

  # Minify CSS and JS on build
  activate :minify_css
  activate :minify_javascript

  #TODO
  #What are these supposed to do (they broke /blog/404 pages when deployed by turning stylesheets relative)
  #why were they enabled by default?
  #activate :relative_assets
  #set :relative_links, true
end

after_build do |builder|
  if check_links_after_build
    begin
      HTMLProofer.check_directory(config[:build_dir], { assume_extension: true, http_status_ignore: [0, 999] }).run
    rescue RuntimeError => e
      puts e
    end
  end
end

def after_configuration
  # add your pre-build, post config.rb execution code here...
  preprocess_races_info()
end
