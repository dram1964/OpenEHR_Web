use strict;
use warnings;

use OpenEHR_Web;

my $app = OpenEHR_Web->apply_default_middlewares(OpenEHR_Web->psgi_app);
$app;

