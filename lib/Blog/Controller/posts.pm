package Blog::Controller::posts;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::posts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub list :Local {
my ($self, $c) = @_;
$c->stash(posts => [$c->model('DB::Post')->all()]);
$c->stash(template => 'posts/list.tt');
}

sub base :Chained('/') :PathPart('posts'):CaptureArgs(0) {
my ($self, $c) = @_;
# Store the ResultSet in stash so it's available for other methods
$c->stash(resultset => $c->model('DB::Post'));
# Print a message to the debug log
$c->log->debug('*** INSIDE BASE METHOD ***');
}


sub form_new :Chained('base'):PathPart('new') :Args(0) {
my ($self, $c) = @_;
# Set the TT template to use
$c->stash(template => 'posts/form.tt');
}

sub form_create_do :Chained('base') :PathPart('create') :Args(0) {
my ($self, $c) = @_;
# Retrieve the values from the form
my $title = $c->request->params->{title} || 'N/A';
my $body = $c->request->params->{body} || 'N/A';
my $post = $c->model('DB::Post')->create({
title => $title,
body => $body,
});
$c->stash(post => $post,template => 'posts/show.tt');
}




sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
my ($self, $c,$id) = @_;
$c->stash(object => $c->stash->{resultset}->find($id));

}
sub delete :Chained('object') :PathPart('delete') :Args(0) {
my ($self, $c) = @_;
$c->stash->{object}->delete;
$c->response->redirect($c->uri_for($self->action_for,('list'),{status_msg=>"post deleted"}));
}





sub show :Chained('object') :PathPart('show'){
	my ($self, $c) = @_;
	my $id = $c->stash->{object}->id ;
	$c->stash(post=>$c->stash->{object});
	$c->stash(comments=> [$c->model('DB::Comment')->search({post_id => $id})]);
	$c->stash(template => 'posts/show.tt');
}


sub comment :Chained('object') :PathPart('comment') :Args(0) {
	my ($self, $c) = @_;
	my $id = $c->stash->{object}->id;
	my $body     = $c->request->params->{body}     || 'N/A';
	my $comment = $c->model('DB::Comment')->create({
		body   => $body,
		post_id  => $c->stash->{object}->id,
		user_id  => $c->session->{__user}{id},
		}); 
	$c->response->redirect($c->uri_for($self->action_for('show'),[$id]));
}



sub edit :Chained('object') :PathPart('edit') :Args(0) {
my ($self, $c) = @_;
my $post = $c->stash->{object};
$c->stash(post => $post,template => 'posts/form_edit.tt');
}

sub update :Chained('object') :PathPart('update') :Args(0) {
my ($self, $c) = @_;
# Retrieve the values from the form
my $title = $c->request->params->{title} || 'N/A';
my $body = $c->request->params->{body} || 'N/A';
# Create the user
my $post = $c->stash->{object}->update({
title => $title,
body => $body,
});
$c->forward('list');
}






=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::posts in posts.');
}



=encoding utf8

=head1 AUTHOR

riham,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
