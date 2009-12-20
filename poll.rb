# Polls the Hacker News website, then adds new items to the database.

require 'nokogiri'
require 'open-uri'
require 'friendfeed'

__DIR__ = File.expand_path( File.dirname( __FILE__ ) )
require "#{__DIR__}/config"
require "#{__DIR__}/model/init"

module TopHN
  class Poller
    MIN_SCORE = 40

    def initialize
      @friendfeed = FriendFeed::Client.new
      @friendfeed.api_login FRIENDFEED_NICK, FRIENDFEED_REMOTE_KEY
    end

    def shortened( uri, title )
      escaped_uri = CGI.escape( uri )
      escaped_title = CGI.escape( title )
      shortened_uri = nil

      3.times do
        begin
          open(
            "http://cli.gs/api/v1/cligs/create?url=#{ escaped_uri }&title=#{ escaped_title }&key=3afeb4d8811734e9e4c917d8cdb1e44e&appid=http%3A%2F%2Fhn.purepistos.net"
          ) do |http|
            shortened_uri = http.read.strip
          end
          break
        rescue OpenURI::HTTPError => e
          case e.message
          when /500 /
          when /502 Bad Gateway/
          else
            raise e
          end
          sleep 2
        end
      end

      shortened_uri
    end

    def poll
      @doc = Nokogiri::HTML( open( 'http://news.ycombinator.com/active' ) )
      @doc.css( 'td.title' ).each do |td|
        a = td.at( 'a' )
        next  if a.nil?
        tr = td.parent.next
        next  if tr.nil?
        subtext = tr.at( 'td.subtext' )
        span = subtext.at( 'span' )
        score = span.text.to_i

        next  if score < MIN_SCORE

        id = span[ 'id' ][ /score_(\d+)/, 1 ]
        item = Models::Item[ id ]
        next  if item

        title = a.text.strip
        uri_hn = subtext.css( 'a' )[ 1 ][ 'href' ]
        uri = a[ 'href' ]
        if uri =~ /^item\?/
          uri = "http://news.ycombinator.com/#{uri}"
        end

        shortened_uri = shortened( uri, title )
        if shortened_uri
          entry = @friendfeed.add_entry( "#{title} #{shortened_uri}" )
          begin
            @friendfeed.add_comment( entry[ 'id' ], "http://news.ycombinator.com/#{uri_hn}" )
          rescue WWW::Mechanize::ResponseCodeError => e
            if e.response_code != "404"
              raise e
            end
          end

          Models::Item.create(
            id: id,
            title: title,
            uri: uri,
            uri_hn: uri_hn,
            score: score
          )

          puts title
        end

      end
    end
  end
end

poller = TopHN::Poller.new
poller.poll
