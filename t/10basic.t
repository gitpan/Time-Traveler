use Test::More tests => 3;
use Time::Traveler;

$text = "Sally is a goober!\n";
$chalkboard = Time::Traveler->new( $text );
is( $chalkboard, "Sally is a goober!\n" );

# This is normal for perl. This shows that $chalkboard finalized its
# value when it was stringified.
SKIP: {
  skip "Some inappropriate time travel occurs - history may be altered when it shouldn't be allowed to.", 1;
  $text = "Brian is a goober!\n";
  is( $chalkboard, "Sally is a goober!\n" );
}

$text = "Sally is a goober!\n";
$chalkboard = Time::Traveler->new( $text );
$text = "Brian is a goober!\n";
is( $chalkboard, "Brian is a goober!\n" );
