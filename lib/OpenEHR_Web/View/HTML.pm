package OpenEHR_Web::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    #TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    TIMER   => 0,
    WRAPPER => 'wrapper.tt2',
);

=head1 NAME

OpenEHR_Web::View::HTML - TT View for OpenEHR_Web

=head1 DESCRIPTION

TT View for OpenEHR_Web.

=head1 SEE ALSO

L<OpenEHR_Web>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
