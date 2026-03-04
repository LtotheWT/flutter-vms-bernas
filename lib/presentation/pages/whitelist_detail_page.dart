import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/whitelist_detail_providers.dart';
import '../widgets/app_filled_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/info_row.dart';

@immutable
class WhitelistDetailRouteArgs {
  const WhitelistDetailRouteArgs({
    required this.entity,
    required this.vehiclePlate,
    required this.checkType,
  });

  final String entity;
  final String vehiclePlate;
  final String checkType;
}

class WhitelistDetailPage extends ConsumerStatefulWidget {
  const WhitelistDetailPage({super.key, required this.args});

  final WhitelistDetailRouteArgs args;

  @override
  ConsumerState<WhitelistDetailPage> createState() =>
      _WhitelistDetailPageState();
}

class _WhitelistDetailPageState extends ConsumerState<WhitelistDetailPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref
          .read(whitelistDetailControllerProvider.notifier)
          .load(
            entity: widget.args.entity,
            vehiclePlate: widget.args.vehiclePlate,
            checkType: widget.args.checkType,
          );
    });
  }

  String get _normalizedCheckType => widget.args.checkType.trim().toUpperCase();

  String get _checkTypeDisplay =>
      _normalizedCheckType == 'O' ? 'Check-Out' : 'Check-In';

  String _displayOrDash(String value) {
    final text = value.trim();
    return text.isEmpty ? '-' : text;
  }

  String get _submitSuccessFallback => _normalizedCheckType == 'O'
      ? 'Whitelist checked OUT successfully.'
      : 'Whitelist checked IN successfully.';

  Future<void> _onConfirm() async {
    final result = await ref
        .read(whitelistDetailControllerProvider.notifier)
        .submit();
    if (!mounted) {
      return;
    }
    final message = result.message.trim().isEmpty
        ? (result.status
              ? _submitSuccessFallback
              : 'Failed to submit whitelist.')
        : result.message.trim();
    showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whitelistDetailControllerProvider);
    final detail = state.detail;
    final canSubmit = detail != null && !state.isLoading && !state.isSubmitting;
    final submitLabel = _normalizedCheckType == 'O'
        ? 'Confirm Check-Out'
        : 'Confirm Check-In';

    return Scaffold(
      appBar: AppBar(title: const Text('Whitelist Details')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: AppFilledButton(
          onPressed: canSubmit ? _onConfirm : null,
          child: state.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(submitLabel),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          if (state.isLoading && !state.hasLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 120),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    InfoRow(label: 'Check Type', value: _checkTypeDisplay),
                    InfoRow(
                      label: 'Vehicle number',
                      value: _displayOrDash(
                        detail?.vehiclePlate ?? widget.args.vehiclePlate,
                      ),
                    ),
                    InfoRow(
                      label: 'IC/Passport',
                      value: _displayOrDash(detail?.ic ?? ''),
                    ),
                    InfoRow(
                      label: 'Name',
                      value: _displayOrDash(detail?.name ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
