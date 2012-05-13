require "rubygems"
require "sequel"

DB = Sequel.postgres(:craigslist)

DB.drop_table(:listings)
DB.create_table(:listings) do
  String :url, :primary_key => true, :unique => true
  String :title
  String :content, :text => true, :null => false
end