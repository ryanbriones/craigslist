require "rubygems"
require "sequel"
require "open-uri"
require "nokogiri"

DB = Sequel.postgres(:craigslist)
Listings = DB[:listings]

5000.step(0, -100) do |offset|
  url = "http://chicago.craigslist.org/chc/apa/index#{offset}.html"
  print "Starting #{offset} #{Time.now}..."
  
  index = open(url).read
  document = Nokogiri::HTML(index)
  document.search("//blockquote/p[not(@align=center)]/a").each do |link|
    next if Listings.first(:url => link.attributes["href"].value)
    
    listing = {
      :url => link.attributes["href"].value,
      :title => link.text.encode("UTF-8")
    }
    listing[:content] = open(listing[:url]).read.encode("UTF-8")
    
    Listings.insert(listing)
  end
  
  puts " Finished #{Time.now}"
end