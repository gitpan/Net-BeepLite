# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 4.t'

#########################

use Test::More tests => 15;
#use Test::More qw(no_plan);

BEGIN { use_ok('Net::BeepLite::BaseProfile');
        use_ok('Net::BeepLite::Message');
        use_ok('Net::BeepLite::Session'); };

#########################

# Testing Net::BeepLite::BaseProfile

# the constructor:
my $profile = Net::BeepLite::BaseProfile->new;
ok(defined $profile, 'constructor works');
isa_ok($profile, 'Net::BeepLite::BaseProfile');

my $prof_uri = "http://foo.bar/profiles/MYPROFILE";
is($profile->uri($prof_uri), $prof_uri, 'profile->uri($val)');
is($profile->uri(), $prof_uri, '$profile->uri()');

my $session = Net::BeepLite::Session->new;

eval { $profile->MSG($session, "blah"); };
like($@, qr/MSG/, 'profile->MSG() croaks');

eval { $profile->startChannelData($session, "blah"); };
like($@, qr/not implemented/i, 'profile->startChannelData()');

for my $type ('MSG', 'RPY', 'ERR', 'ANS', 'NUL') {
  my $message = new Net::BeepLite::Message(Type => $type,
					   Channel => 1,
					   Payload => "some payload");
  eval { $profile->handle_message($session, $message); };
  like($@, qr/$type/, "profile->handle_message($type)");
}

my $message =  new Net::BeepLite::Message(Type => 'UNK',
					   Channel => 1,
					   Payload => "some payload");
eval { $profile->handle_message($session, $message); };
like($@, qr/unknown/, 'profile->handle_message(UNK)');
