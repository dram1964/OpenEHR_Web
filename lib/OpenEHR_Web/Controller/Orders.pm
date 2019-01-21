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

sub list :Path('list') :Args(0) {
    my ( $self, $c ) = @_;
    my $states = [ qw/ planned scheduled complete aborted / ];
    my $stmt = << "END_STMT";
select a/uid/value as compositionid, 
    c/narrative/value as narrative, 
    c/uid/value as requestid, 
    c/protocol[at0008]/items[at0010]/value/value as uniquemessageid, 
    f/items[at0001]/value/value as request_start_date, 
    f/items[at0002]/value/value as request_end_date,  
    d/ism_transition/current_state/value as current_state,c/activities[at0001]/description[at0009]/items[at0148]/value/value as service_type,
    d/ism_transition/current_state/defining_code/code_string as current_state_code, 
    e/ehr_status/subject/external_ref/id/value as nhsnumber
    from EHR e 
    contains COMPOSITION a[openEHR-EHR-COMPOSITION.report.v1]
    contains (INSTRUCTION c[openEHR-EHR-INSTRUCTION.request.v0]
    contains CLUSTER f[openEHR-EHR-CLUSTER.information_request_details_gel.v0]
    AND ACTION d[openEHR-EHR-ACTION.service.v0])
    where c/activities[at0001]/description[at0009]/items[at0121]/value = 'GEL Information data request'
END_STMT
    my $query = OpenEHR::REST::AQL->new();
    $query->statement($stmt);
    $query->run_query;
    if ($query->err_msg) {
        $c->stash->{error_msg} = $query->err_msg;
    }

    $c->stash(orders => $query->resultset);

    $c->stash(
        states  => $states,
        template => 'orders/display.tt2',
    );
}

sub list_by_state :Path('list_by_state') :Args(1) {
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

sub search_by_uid :Path('search_by_uid') :Args(0) {
    my ($self, $c) = @_;
    my $uid = $c->request->params->{uid};

    my $query = OpenEHR::REST::AQL->new();
    $query->find_ehr_by_uid($uid);


    my $ehrid = $query->resultset->[0]->{ehrid};
    my $ptnumber = $query->resultset->[0]->{ptnumber};

    $c->forward($c->controller('Compositions'), 'display_flat', [$ehrid, $ptnumber, $uid]);
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
