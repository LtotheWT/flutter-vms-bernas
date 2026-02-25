import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({
    super.key,
    required this.title,
    this.description,
    this.scannerBuilder,
  });

  final String title;
  final String? description;

  /// Optional test hook to replace the live scanner widget in widget tests.
  final Widget Function(
    void Function(String value) onScanned,
    void Function(String message) onError,
  )?
  scannerBuilder;

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasCompleted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleScannedValue(String value) {
    final text = value.trim();
    if (_hasCompleted || text.isEmpty || !mounted) {
      return;
    }
    _hasCompleted = true;
    Navigator.of(context).pop(text);
  }

  void _handleErrorMessage(String message) {
    final nextMessage = message.trim().isEmpty
        ? 'Unable to start camera scanner.'
        : message.trim();
    if (!mounted || _errorMessage == nextMessage) {
      return;
    }
    // Avoid setState during scanner build callbacks.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _errorMessage == nextMessage) {
        return;
      }
      setState(() {
        _errorMessage = nextMessage;
      });
    });
  }

  String _errorTextFrom(MobileScannerException error) {
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      return 'Camera permission denied. Please allow camera access and try again.';
    }
    return error.errorCode.message;
  }

  Future<void> _retry() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      await _controller.start();
    } on MobileScannerException catch (error) {
      _handleErrorMessage(_errorTextFrom(error));
    } catch (_) {
      _handleErrorMessage('Unable to start camera scanner.');
    }
  }

  Widget _buildScannerView() {
    if (widget.scannerBuilder != null) {
      return widget.scannerBuilder!(_handleScannedValue, _handleErrorMessage);
    }

    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        final code = capture.barcodes.isEmpty
            ? ''
            : (capture.barcodes.first.rawValue ?? '');
        _handleScannedValue(code);
      },
      errorBuilder: (context, error) {
        _handleErrorMessage(_errorTextFrom(error));
        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: Icon(
              Icons.qr_code_scanner,
              size: 52,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        );
      },
      placeholderBuilder: (context) {
        return const ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.description?.trim().isNotEmpty == true
        ? widget.description!.trim()
        : 'Align QR code inside the frame to scan.';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Close scanner',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildScannerView()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
