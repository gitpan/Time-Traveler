package Time::Traveler;
use strict;
use warnings;
use overload(# These open up holes in the fabric of time by which to
             # allow later time travel.
             map( { my $method = $_;
                    $method =>
                    sub { shift->_OpenAHoleInTime( @_, $method ) } }
                  qw( + - * / ^ ** << >> x . & ^ | ! neg ~ ),
                  qw( < <= > >= == != <=> ),
                  qw( lt le gt ge eq ne cmp ),
                  qw( ++ -- ),
                  qw( atan2 cos sin exp abs log sqrt int ) ),
             map( { my $method = $_;
                    $method => sub { shift->_TimeTravel( $method ) } }
                  '""', '0+', 'bool' ),
             
             '=' => \ &_NewUniverse,
             nomethod => \ &_OpenAHoleInTime );
use vars qw( $VERSION );
use B 'svref_2object';

$VERSION = 0.01;

sub new {
     if ( 1 == svref_2object( \ $_[1] )->REFCNT ) {
         return $_[1];
     }
     else {
        return bless [ \ $_[1] ], $_[0];
     }
}

sub import {
    my $class = shift;
    
    # This is undocumented and I'm not sure its useful for anything. I
    # have this here so I can play with it.
    
    if ( grep ':constant' eq $_, @_ ) {
	overload::constant( integer => sub { __PACKAGE__->new( $_[0] ) },
			    float => sub { __PACKAGE__->new( $_[0] ) },
			    binary => sub { __PACKAGE__->new( $_[0] ) },
			    'q' => sub { __PACKAGE__->new( $_[0] ) },
			    'qq' => sub { __PACKAGE->new( $_[0] ) } );
    }
    
    1;
}

sub _TimeTravel {
    my ( $self, $context ) = @_;
    
    my $value = ${shift @$self};
    while ( @$self ) {
	my ( $op, $inverted, $new_value ) = splice @$self, 0, 3;
	$inverted = $inverted ? 1 : 0;
	$new_value = $$new_value;
	
	my ( $a, $b ) = ( $inverted
			  ? ( $new_value, $value )
			  : ( $value, $new_value ) );
	
 	if ( '+' eq $op ) { $value = $a + $b }
 	elsif ( '-' eq $op ) { $value = $a - $b }
 	elsif ( '*' eq $op ) { $value = $a * $b }
 	elsif ( '/' eq $op ) { $value = $a / $b }
 	elsif ( '^' eq $op ) { $value = $a ^ $b }
 	elsif ( '**' eq $op ) { $value = $a ** $b }
 	elsif ( '<<' eq $op ) { $value = $a << $b }
 	elsif ( '>>' eq $op ) { $value = $a >> $b }
 	elsif ( 'x' eq $op ) { $value = $a x $b }
 	elsif ( '.' eq $op ) { $value = $a . $b }
 	elsif ( '&' eq $op ) { $value = $a & $b }
 	elsif ( '^' eq $op ) { $value = $a ^ $b }
 	elsif ( '|' eq $op ) { $value = $a | $b }
 	elsif ( '!' eq $op ) { $value = ! $a }
	elsif ( 'neg' eq $op ) { $value = - $a }
 	elsif ( '~' eq $op ) { $value = ~ $a }
 	elsif ( '<' eq $op ) { $value = $a < $b }
 	elsif ( '<=' eq $op ) { $value = $a <= $b }
	elsif ( '>' eq $op ) { $value = $a > $b }
	elsif ( '>=' eq $op ) { $value = $a >= $b }
	elsif ( '==' eq $op ) { $value = $a == $b }
	elsif ( '!=' eq $op ) { $value = $a != $b }
	elsif ( '<=>' eq $op ) { $value = $a <=> $b }
	elsif ( 'lt' eq $op ) { $value = $a lt $b }
	elsif ( 'le' eq $op ) { $value = $a le $b }
	elsif ( 'gt' eq $op ) { $value = $a gt $b }
	elsif ( 'ge' eq $op ) { $value = $a ge $b }
	elsif ( 'eq' eq $op ) { $value = $a eq $b }
	elsif ( 'ne' eq $op ) { $value = $a ne $b }
	elsif ( 'cmp' eq $op ) { $value = $a cmp $b }
	elsif ( '++' eq $op ) { $value = ++ $a }
	elsif ( '--' eq $op ) { $value = -- $a }
	elsif ( 'atan2' eq $op ) { $value = atan2 $a, $b }
	elsif ( 'cos' eq $op ) { $value = cos $a }
	elsif ( 'sin' eq $op ) { $value = sin $a }
	elsif ( 'exp' eq $op ) { $value = exp $a }
	elsif ( 'abs' eq $op ) { $value = abs $a }
	elsif ( 'log' eq $op ) { $value = log $a }
	elsif ( 'sqrt' eq $op ) { $value = sqrt $a }
	elsif ( 'int' eq $op ) { $value = int $a }
 	else { die "Invalid op $op" }
    }
    
    @$self = \ $value;
    return $value;
}

sub _NewUniverse {
    my $self = shift;
    my $new = ref( $self )->new;
    @$new = @$self;
    $new;
}

sub _OpenAHoleInTime {
    my $self = $_[0];
    my $class = ref $_[0];
    my $new_value = \ $_[1];
    my $inverted = $_[2];
    my $op = $_[3];
    
    bless [ @$self,
	    $op, $inverted, $new_value ];
}

1;

__END__

=head1 NAME

Time::Traveler - Allows "retroactive" changes of variables aka values are not evaluated immediately.

=head1 DESCRIPTION

This module allows you to use overloaded values to delay when a
value's value is actually computed. I wrote this so I could return a
value from one of my functions to some user code and later change my
mind about the value I should have returned.

=head1 SYNOPSIS

 $val = "Sally is a goober";
 $_ = Time::Traveler->new( $val );
 $val = "I will not insult Sally.\n" x 100;
 print; # Shows the updated $val, not the original $val.


=head1 Methods

=head2 Time::Traveler->new( $val )

You are expected to pass in a single variable to the
method. Time::Traveler will take a reference to this value so that if
you change its value later, Time::Traveler will use that new value
instead of your original value.

The *only* correct way to use this is to pass in a variable. You may
pass in constants or the result of expressions but they can't be
altered later because you aren't going to be sharing a reference with
Time::Traveler.

Ok.

 $elt1 = Time::Traveler->new( $h->{ 'foo' } );
 $elt2 = Time::Traveler->new( $ary[ 10000 ] );
 $elt3 = Time::Traveler->new( $var );

Not ok.

 $elt4 = Time::Traveler->new( 42 );
 $elt5 = Time::Traveler->new( foo() );

=head1 AUTHOR

Joshua ben Jore, C<< <jjore@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-time-traveler@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Time-Traveler>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Corion of perlmonks.org

=head1 COPYRIGHT & LICENSE

Copyright 2005 Joshua ben Jore, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
