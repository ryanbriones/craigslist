# craigslist

Scripts I use to get decent results from craigslist.

1. Download last N listings from craigslist
2. Find dups by exact title match
3. Attempt to grab search data from content (price, bedrooms, etc) and stuff into elasticsearch
4. Search based on my criteria
5. WIN

# Requirements

* Ruby
* Bundler
* postgresql
* elasticsearch

# TODO

Things I probably wont do since before actually finding an apartment

* When analyzing listings, search for images within a listing, stream their contents,
  hash the contents and index those hashes. Use this to create a "unique images ratio"
  and consider anything less than a threshold ratio to be "duplicate". For instance
  if a listing has 10 images, but 9 of them appear in other listings consider this
  listing a duplicate and do not index it for search.
* Learn how to create a better search using elasticsearch. Scoring, boosting, etc.
* Make the load/analyze process 1 script/class
* Use Twitter Storm to stream/analze in new listings and send new listings to myself via
  email when they match my criteria

# LICENSE

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.