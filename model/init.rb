require 'm4dbi'

$dbh = DBI.connect( 'DBI:Pg:top_hn', 'top_hn', '' )

__DIR__ = File.expand_path( File.dirname( __FILE__ ) )
require "#{__DIR__}/item"
