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
    my $aql_info_orders = << "END_AQL";
    select
    e/ehr_id/value as subject_ehr_id,
    e/ehr_status/subject/external_ref/namespace as subject_id_type,
    e/ehr_status/subject/external_ref/id/value as subject_id,
    c/uid/value as composition_uid,
    i/narrative/value as narrative,
    c/name/value as order_type,
    c/composer/name as ordered_by,
    i/uid/value as order_id,
    i/protocol[at0008]/items[at0010]/value/value as unique_message_id,
    i/activities[at0001]/timing/value as start_date,
    i/expiry_time/value as end_date,
    c/context/start_time/value as data_start_date,
    c/context/end_time/value as data_end_date,
    i/activities[at0001]/description[at0009]/items[at0148]/value/value as service_type,
    a/ism_transition/current_state/value as current_state,
    a/ism_transition/current_state/defining_code/code_string as current_state_code
    from EHR e
    contains COMPOSITION c[openEHR-EHR-COMPOSITION.report.v1]
    contains (INSTRUCTION i[openEHR-EHR-INSTRUCTION.request.v0]
    and ACTION a[openEHR-EHR-ACTION.service.v0])
    where i/activities[at0001]/description[at0009]/items[at0121]/value = 'GEL Information data request'
    and i/activities[at0001]/description[at0009]/items[at0148]/value/value = 'pathology'
    and a/ism_transition/current_state/value = '$state'
END_AQL
    my $query = OpenEHR::REST::AQL->new();
    $query->statement($aql_info_orders);
    $query->run_query;
    if ( $query->response_code eq '204') {
        $c->stash->{error_msg} = "No $state orders found";
    }
    elsif ( $query->err_msg ) {
        $c->log->debug("Query: " . $aql_info_orders );
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
