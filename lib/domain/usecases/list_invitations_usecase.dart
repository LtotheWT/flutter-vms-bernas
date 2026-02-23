import '../entities/invitation_list_item_entity.dart';
import '../entities/invitation_listing_filter_entity.dart';
import '../repositories/invitation_repository.dart';

class ListInvitationsUseCase {
  const ListInvitationsUseCase(this._repository);

  final InvitationRepository _repository;

  Future<List<InvitationListItemEntity>> call({
    required InvitationListingFilterEntity filter,
  }) {
    return _repository.listInvitations(filter: filter);
  }
}
