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
      response[ 'Content-Type' ] = 'application/xml'

      items = Models::Item.s(
        "SELECT * FROM items ORDER BY time_added DESC LIMIT 50"
      ).map { |item|
        uri_thread = "http://news.ycombinator.com/#{ escape_xml item.uri_hn }"
        %{
    <item>
      <title>#{ escape_xml item.title }</title>
      <link>#{ escape_xml item.uri }</link>
      <guid>#{ uri_thread }</guid>
      <description>#{ uri_thread }</description>
    </item>
        }
      }

      %{<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
  <title>Top Hacker News</title>
  <link>http://hn.purepistos.net</link>
  <atom:link href="http://hn.purepistos.net/rss" rel="self" type="application/rss+xml"/>
  <description>An RSS feed of only the better Hacker News items</description>
  #{items.join}
</channel>
</rss>
      }
    end
  end
end

Ramaze.start( :port => 8026, :adapter => :thin, :mode => :live )
