require "rubygems"
require "sequel"
require "httparty"
require "json"
require "digest/sha1"
require "time"

Sequel.default_timezone = :utc
DB = Sequel.postgres(:craigslist)
Listings = DB[:listings]

select_sql = <<-SQL
SELECT l.title, l.url, l.posted_at, l.content FROM listings l
LEFT OUTER JOIN 
	(SELECT dp.url FROM duplicates dp
		INNER JOIN listings lp ON lp.url = dp.url
		ORDER BY lp.posted_at
		LIMIT 20000) d ON d.url = l.url
WHERE d.url IS NULL
ORDER BY l.posted_at DESC
LIMIT 2000
SQL

DB.fetch(select_sql).each do |listing|
  document = listing
  document[:posted_at] = listing[:posted_at].iso8601
  
  if rent = listing[:title].match(/\$([\d,]+)/)
    document[:rent] = rent[1].gsub(",", "").to_i
  end
  
  if bedrooms = listing[:title].match(/(\d)b(?:r|d)/)
    document[:bedrooms] = bedrooms[1].to_i
  end
  
  if listing[:content].match(/dogs are OK/)
    document[:dogs_ok] = true
  else
    document[:dogs_ok] = false
  end
  
  if listing[:content].match(/<img/)
    document[:has_image] = true
  else
    document[:has_image] = false
  end
  
  if listing[:content].match(/(?:free|in-unit|in\s+unit)\s+laundry/i)
    document[:in_unit] = true
  else
    document[:in_unit] = false
  end
  
  HTTParty.put("http://localhost:9200/craigslist/listing/#{Digest::SHA1.hexdigest(listing[:url])}", :body => document.to_json)
end