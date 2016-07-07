=head1 LICENSE

Copyright [2016] EMBL-European Bioinformatics Institute
Copyright [2016] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::REST::Model::Regulatory;

use Moose;
use Catalyst::Exception qw(throw);
use Bio::EnsEMBL::Utils::Scalar qw/wrap_array/;
use Scalar::Util qw/weaken/;
extends 'Catalyst::Model';

with 'Catalyst::Component::InstancePerContext';

has 'context' => (is => 'ro', weak_ref => 1);

sub build_per_context_instance {
  my ($self, $c, @args) = @_;
  weaken($c);
  return $self->new({ context => $c, %$self, @args });
}

sub fetch_regulatory {
  my $self    = shift;
  my $regf_id = shift ||
   Catalyst::Exception->throw("No regulatory feature stable ID given. Please specify an stable ID to retrieve from this service");

  my $c          = $self->context;
  my $species    = $c->stash->{species};

  my $rf_a = $c->model('Registry')->get_adaptor($species, 'funcgen', 'RegulatoryFeature');
  my $rf = $rf_a->fetch_by_stable_id($regf_id);
  if(! defined $rf) {
    Catalyst::Exception->throw("$regf_id not found for $species");
  }
  my $sum = $rf->summary_as_hash();
  return([$sum]);

}

#If required look at Variation::to_hash for example of enriched hash
#and additional data types that can be embedded



with 'EnsEMBL::REST::Role::Content';

__PACKAGE__->meta->make_immutable;

1;
