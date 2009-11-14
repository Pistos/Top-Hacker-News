# Polls the Hacker News website, then adds new items to the database.

require 'nokogiri'
require 'open-uri'

require 'model/init'

module TopHN
  class Poller
    MIN_SCORE = 40

    def initialize
    end

    def poll
      @doc = Nokogiri::HTML( open( 'http://news.ycombinator.com/active' ) )
      @doc.css( 'td.title' ).each do |td|
        a = td.at( 'a' )
        if a
          tr = td.parent.next
          if tr
            subtext = tr.at( 'td.subtext' )
            span = subtext.at( 'span' )
            score = span.text.to_i

            next  if score < MIN_SCORE

            id = span[ 'id' ][ /score_(\d+)/, 1 ]
            item = Models::Item[ id ]
            next  if item

            title = a.text.strip
            uri_hn = subtext.css( 'a' )[ 1 ][ 'href' ]

            Models::Item.create(
              id: id,
              title: title,
              uri: a[ 'href' ],
              uri_hn: uri_hn,
              score: score
            )
            puts title
          end
        end
      end
    end
  end
end

poller = TopHN::Poller.new
poller.poll
