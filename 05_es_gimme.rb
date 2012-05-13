require "rubygems"
require "httparty"
require "json"
require "tzinfo"

Chicago = TZInfo::Timezone.get("America/Chicago")

search = {
  :filter => {
    :and => {
      :filters => [
        {
          :range => {
            :rent => {
              :from => 1000,
              :to => 1999
            },
          },
        },

        {
          :term => {
            :dogs_ok => true,
          }
        },
        
        {
          :term => {
            :has_image => true
          }
        },
        
        {
          :term => {
            :in_unit => true
          }
        },
        
        {
          :query => {
            :query_string => {
              :query => '("wicker park" OR "lincoln park" OR "logan square" OR bucktown) AND deck',
              :fields => ["content", "title"]
            }
          }
        }
      ]
    }
  },
  
  :sort => {:posted_at => {:order => "desc"}},
  :from => 0, :size => 20
}

HTTParty.get("http://localhost:9200/craigslist/listing/_search", :body => search.to_json)["hits"]["hits"].each do |hit|
  puts "#{Chicago.utc_to_local(hit["_source"]["posted_at"]).strftime("%Y-%m-%d %I:%M%p")} - #{hit["_source"]["title"]} #{hit["_source"]["url"]}"
end