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

=head2 list

Fetch all Compositions and pass to compositions/list.tt2 in stash to be displayed
Each result in the 'compositions' resultset will have the following keys: 
name - composition name
uid  - composition UID
submitted - datetime composition was submitted
template_id - template_id used in submission
report_id   - report ID

=cut 

sub list :Path('list') :Args(0) {
    my ($self, $c) = @_;
    my $stmt = << "END_STMT";
    select 
    c/name/value as name,
    c/uid/value as uid,
    c/archetype_details/template_id/value as template_id,
    c/context/start_time/value as submitted,
    c/context/other_context[at0001]/items[at0002]/value/value as report_id
    from Composition c
END_STMT
    my $query = OpenEHR::REST::AQL->new();
    $query->statement($stmt);
    $query->run_query;
    if ($query->err_msg) {
        $c->stash->{error_msg} = $query->err_msg;
    }

    $c->stash(compositions => $query->resultset);


    $c->stash(template => 'compositions/list.tt2');
}

=head2 search_by_uid

Searches for a composition by uid and forwards to display_flat method

=cut

sub search_by_uid :Path('search_by_uid') :Args(0) {
    my ($self, $c) = @_;
    my $uid = $c->request->params->{uid};

    my $query = OpenEHR::REST::AQL->new();
    $query->find_ehr_by_uid($uid);


    my $ehrid = $query->resultset->[0]->{ehrid};
    my $ptnumber = $query->resultset->[0]->{ptnumber};

    $c->forward($c->controller('Compositions'), 'display_flat', [$ehrid, $ptnumber, $uid]);
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
    #$c->log->debug($json_string);
    #$json_string =~ s/'_name'/'name'/;
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
