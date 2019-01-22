package CyrusWorks::Remove;
use 5.20.0;
use Moo;
use CyrusWorks::Pragmas;
use JSON;

sub get_containers_json($self) {
  my $output = `docker ps -a --format='{ "id" : {{json .ID}}, "image" : {{json .Image}}, "command" : {{json .Command}}, "status" : {{json .Status}} }'`;
  my @lines = split "\n", $output;
  my $json = '[' . join( ',', @lines ) . ']';;
  return $json;
}

sub get_containers($self) {
  my $j = JSON->new;
  my $data = $j->decode( $self->get_containers_json );
  return $data;
}

sub get_relevant_containers($self) {
  my $containers = $self->get_containers;
  my @relevant_containers;
  foreach my $container ( $containers->@* ) {
    next if ! ( $container->{status} =~ /^Exited/ );
    next if ! ( $container->{image} =~ /^jessie:build/ );
    next if $container->{command} ne '"/entrypoint.sh"';
    push @relevant_containers, $container;
  }
  return \@relevant_containers;
}

sub remove_old_containers($self) {
  my $containers_to_remove = $self->get_relevant_containers;
  foreach my $container ( $containers_to_remove->@* ) {
    say join( ' ', 'Removing container', $container->{id}, $container->{image} );
    system( '/usr/bin/docker', 'rm', $container->{id} );
  }
}

1;
