package OpenEHR_Web::Controller::Compositions;
use Moose;
use namespace::autoclean;
use OpenEHR::REST::Composition;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

OpenEHR_Web::Controller::Compositions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched OpenEHR_Web::Controller::Compositions in Compositions.');
}

sub display :Local :Args(3) {
    my ($self, $c, $ehrid, $ptnumber, $uid) = @_;

    my $query = OpenEHR::REST::Composition->new();
    $query->find_by_uid($uid);
    if ($query->err_msg) {
        $c->stash->{error_msg} = $query->err_msg;
    }
    $c->stash(
        composition => $query->composition_response,
        ehrid       => $ehrid,
        ptnumber    => $ptnumber,
        uid         => $uid,
        template    => 'compositions/display.tt2',
    );
}

sub display_flat :Local :Args(3) {
    my ($self, $c, $ehrid, $ptnumber, $uid) = @_;

    my $query = OpenEHR::REST::Composition->new();
    $query->request_format('FLAT');
    $query->find_by_uid($uid);
    if ($query->err_msg) {
        $c->stash->{error_msg} = $query->err_msg;
    }
    my $json_string = to_json($query->composition_response);
    $c->log->debug($json_string);
    $json_string =~ s/'_name'/'name'/;
    my $composition = from_json($json_string);
    $c->stash(
        composition => $query->composition_response,
        ehrid       => $ehrid,
        ptnumber    => $ptnumber,
        uid         => $uid,
        template    => 'compositions/display_flat.tt2',
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
