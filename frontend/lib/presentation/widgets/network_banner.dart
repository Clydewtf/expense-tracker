import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/network_service.dart';


class NetworkBanner extends StatefulWidget {
  final Widget child;
  const NetworkBanner({super.key, required this.child});

  @override
  State<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends State<NetworkBanner> {
  bool _wasOnline = true;
  bool _isVisible = false;
  String _message = '';
  Color _color = Colors.transparent;
  IconData _icon = Icons.wifi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overlayColor = theme.colorScheme.surface.withValues(alpha: 0.95);

    return Consumer<NetworkService>(
      builder: (context, network, _) {
        final isOnline = network.isOnline;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isOnline == _wasOnline) return;
          _wasOnline = isOnline;

          if (!isOnline) {
            setState(() {
              _message = 'No network connection';
              _color = Colors.redAccent;
              _icon = Icons.wifi_off_rounded;
              _isVisible = true;
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && !_wasOnline) {
                setState(() => _isVisible = false);
              }
            });
          } else {
            setState(() {
              _message = 'Connection restored';
              _color = Colors.green;
              _icon = Icons.check_circle_rounded;
              _isVisible = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _wasOnline) {
                setState(() => _isVisible = false);
              }
            });
          }
        });

        return Stack(
          children: [
            widget.child,
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: _isVisible ? kToolbarHeight + 8 : -80,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _isVisible ? 1 : 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: overlayColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: _color.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_icon, color: _color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}