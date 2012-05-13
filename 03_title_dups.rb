require "rubygems"
require "sequel"
require "logger"

DB = Sequel.postgres(:craigslist)
begin
  DB.create_table(:duplicates) do
    String :url
    String :duplicates
  end
rescue Sequel::DatabaseError => e
  unless e.message.match(/relation.+already exists/)
    raise
  end
end


Listings = DB[:listings]
Duplicates = DB[:duplicates]

last_n_urls = Listings.select(:url).order(:posted_at.desc).limit(40000).map { |l| l[:url] }

# DB.loggers << Logger.new($stdout)

Listings.select(:url, :title)
  .filter(:url => last_n_urls)
  .order(:posted_at.asc).each do |old_listing|
    new_duplicates_sql = <<-SQL
    SELECT l.url FROM listings l
    LEFT OUTER JOIN duplicates d ON d.url = l.url
    WHERE l.url != ? AND d.url IS NULL AND l.title = ?
    SQL
    
    DB.fetch(new_duplicates_sql, old_listing[:url], old_listing[:title]).each do |new_duplicated_listing|
      Duplicates.insert(:url => new_duplicated_listing[:url], :duplicates => old_listing[:url])
      puts "#{old_listing[:title]}: #{new_duplicated_listing[:url]} duplicates #{old_listing[:url]}"
    end
end