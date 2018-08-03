use strict;
use warnings;
use Test::More;


use Catalyst::Test 'OpenEHR_Web';
use OpenEHR_Web::Controller::Orders;

ok( request('/orders')->is_success, 'Request should succeed' );
done_testing();
