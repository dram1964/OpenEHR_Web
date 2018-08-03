use strict;
use warnings;
use Test::More;


use Catalyst::Test 'OpenEHR_Web';
use OpenEHR_Web::Controller::Compositions;

ok( request('/compositions')->is_success, 'Request should succeed' );
done_testing();
