package OpenEHR_Web::Controller::Ehrs;
use Moose;
use namespace::autoclean;
use OpenEHR::REST::AQL;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

OpenEHR_Web::Controller::Ehrs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    

    $c->response->body('Matched OpenEHR_Web::Controller::Ehrs in Ehrs.');
}

=head2 list

Fetch all Ehrs and pass to ehrs/list.tt2 in stash to be displayed

=cut 

sub list :Local {
    my ($self, $c) = @_;
    my $stmt = << "END_STMT";
    select e/ehr_id/value as ehrid, e/ehr_status/subject/external_ref/id/value as ptnumber,
    e/ehr_status/subject/external_ref/namespace as namespace, c/name/value as composition_type,
    c/uid/value as uid
    from EHR e
    contains Composition c
END_STMT
    my $query = OpenEHR::REST::AQL->new();
    $query->statement($stmt);
    $query->run_query;
    if ($query->err_msg) {
        $c->stash->{error_msg} = $query->err_msg;
    }

    $c->stash(ehrs => $query->resultset);


    $c->stash(template => 'ehrs/list.tt2');
}

=head2 search_by_subject_id

Fetch an Ehr and its compostions for display

=cut

sub search_by_subject_id :Path('search_by_subject_id') :Args(0) {
    my ( $self, $c ) = @_;
    my $subject_id = $c->request->params->{subject_id};
    my $stmt = << "END_STMT";
    select e/ehr_id/value as ehrid, e/ehr_status/subject/external_ref/id/value as ptnumber,
    e/ehr_status/subject/external_ref/namespace as namespace, c/name/value as composition_type,
    c/uid/value as uid, c/context/start_time/value as submitted
    from EHR e
    contains Composition c
    where e/ehr_status/subject/external_ref/id/value = '$subject_id'
END_STMT
    $c->log->debug($stmt);
    my $query = OpenEHR::REST::AQL->new();
    $query->statement($stmt);
    $query->run_query;
    if ($query->err_msg) {
        $c->stash->{error_msg} = $query->err_msg;
    }

    $c->stash(ehr => $query->resultset);
    $c->stash(template => 'ehrs/list_by_subject.tt2');
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
