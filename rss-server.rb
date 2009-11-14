require 'ramaze'
require 'model/init'

module TopHN
  class MainController < Ramaze::Controller
    def index
      items = Models::Item.s(
        "SELECT * FROM items ORDER BY time_added DESC LIMIT 50"
      ).map { |item|
        %{
    <item>
      <title>#{item.title}</title>
      <link>#{item.uri}</link>
      <description>http://news.ycombinator.com/#{item.uri_hn}</description>
    </item>
        }
      }

      %{<?xml version="1.0" ?>
<rss version="2.0">
<channel>
  <title>Top Hacker News</title>
  <link>http://hn.purepistos.net</link>
  <description>An RSS feed of only the better Hacker News items</description>
  #{items.join}
</channel>
</rss>
      }
    end
  end
end

Ramaze.start( :port => 8026, :adapter => :thin )