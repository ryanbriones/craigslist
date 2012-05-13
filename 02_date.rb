require "rubygems"
require "sequel"
require "time"

DB = Sequel.postgres(:craigslist)
begin
  DB.alter_table(:listings) do
    add_column :posted_at, Time
  end
rescue Sequel::DatabaseError => e
  unless e.message.match(/column.+already exists/)
    raise
  end
end
Listings = DB[:listings]

puts Listings.filter(:posted_at => nil).count

Listings.filter(:posted_at => nil).each do |listing|
  date = listing[:content].match(/Date:\s+(\d{4}-\d{1,2}-\d{1,2}),\s+(\d{1,2}:\d{1,2}(?:AM|PM)\s+(?:\w+))/i)
  if date
    time = Time.parse("#{date[1]} #{date[2]}").utc
    Listings.filter(:url => listing[:url]).update(:posted_at => time)
  else
    $stderr.puts "DELETED: #{listing[:url]}"
    Listings.filter(:url => listing[:url]).delete
  end
end