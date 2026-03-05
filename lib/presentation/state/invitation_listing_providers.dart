import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../domain/entities/invitation_list_item_entity.dart';
import '../../domain/entities/invitation_listing_filter_entity.dart';
import '../../domain/usecases/list_invitations_usecase.dart';
import 'invitation_add_providers.dart';

final listInvitationsUseCaseProvider = Provider<ListInvitationsUseCase>((ref) {
  final repository = ref.read(invitationRepositoryProvider);
  return ListInvitationsUseCase(repository);
});

@immutable
class InvitationListingState {
  const InvitationListingState({
    this.items = const <InvitationListItemEntity>[],
    this.isLoading = false,
    this.errorMessage,
    this.hasLoaded = false,
  });

  final List<InvitationListItemEntity> items;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoaded;

  InvitationListingState copyWith({
    List<InvitationListItemEntity>? items,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? hasLoaded,
  }) {
    return InvitationListingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

const Object _unset = Object();

final invitationListingControllerProvider =
    NotifierProvider.autoDispose<
      InvitationListingController,
      InvitationListingState
    >(InvitationListingController.new);

class InvitationListingController extends Notifier<InvitationListingState> {
  @override
  InvitationListingState build() => const InvitationListingState();

  Future<void> loadInitial() {
    return _fetch(filter: const InvitationListingFilterEntity());
  }

  Future<void> applyFilters(InvitationListingFilterEntity filter) {
    return _fetch(filter: filter);
  }

  Future<void> _fetch({required InvitationListingFilterEntity filter}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final useCase = ref.read(listInvitationsUseCaseProvider);
      final items = _sortByCreateDateDesc(await useCase(filter: filter));
      state = state.copyWith(
        items: items,
        isLoading: false,
        errorMessage: null,
        hasLoaded: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: toDisplayErrorMessage(
          error,
          fallback: 'Failed to load invitation listing.',
        ),
        hasLoaded: true,
      );
    }
  }

  List<InvitationListItemEntity> _sortByCreateDateDesc(
    List<InvitationListItemEntity> items,
  ) {
    final indexed = items.indexed.toList(growable: false);
    indexed.sort((a, b) {
      final left = DateTime.tryParse(a.$2.createDate.trim());
      final right = DateTime.tryParse(b.$2.createDate.trim());

      if (left != null && right != null) {
        return right.compareTo(left);
      }
      if (left != null && right == null) {
        return -1;
      }
      if (left == null && right != null) {
        return 1;
      }
      return a.$1.compareTo(b.$1);
    });
    return indexed.map((entry) => entry.$2).toList(growable: false);
  }
}
