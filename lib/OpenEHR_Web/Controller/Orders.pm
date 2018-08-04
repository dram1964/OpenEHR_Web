package OpenEHR_Web::Controller::Orders;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

OpenEHR_Web::Controller::Orders - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched OpenEHR_Web::Controller::Orders in Orders.');
}

=head2 list

Shows a welcome page for Orders

=cut 

sub list :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $states = [ qw/ planned scheduled completed aborted / ];
    $c->stash(
        states  => $states,
        template => 'orders/display.tt2',
    );
}

sub list_by_state :Path :Args(1) {
    my ( $self, $c, $state ) = @_;
    my $query = OpenEHR::REST::AQL->new();
    $query->find_orders_by_state($state);
    if ( $query->response_code eq '204') {
        $c->stash->{error_msg} = "No $state orders found";
    }
    elsif ( $query->err_msg ) {
        $c->stash->{error_msg} = $query->err_msg;
    }
    elsif (defined($query->resultset)) {
        $c->stash->{compositions} = $query->resultset;
    }

    $c->stash(
        template    => 'orders/list_by_state.tt2',
    );
}




=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
