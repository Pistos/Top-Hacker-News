require 'ramaze'
require 'model/init'

module TopHN
  class MainController < Ramaze::Controller
    XML_MAP = {
      '&' => '&amp;',
      '<' => '&lt;',
      '>' => '&gt;',
      "'" => '&apos;',
      '"' => '&quot;',
    }

    def escape_xml( s )
      s.gsub( /[&<>'"]/ ) do |m|
        XML_MAP[ m ] || m
      end
    end

    def rss
      items = Models::Item.s(
        "SELECT * FROM items ORDER BY time_added DESC LIMIT 50"
      ).map { |item|
        %{
    <item>
      <title>#{ escape_xml item.title }</title>
      <link>#{ escape_xml item.uri }</link>
      <description>http://news.ycombinator.com/#{ escape_xml item.uri_hn }</description>
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

Ramaze.start( :port => 8026, :adapter => :thin, :mode => :live )
