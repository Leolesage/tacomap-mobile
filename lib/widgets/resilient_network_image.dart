import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';
import '../theme/app_theme.dart';

class ResilientNetworkImage extends StatefulWidget {
  final String photoUrl;
  final String photoPath;
  final BoxFit fit;
  final Widget fallback;

  const ResilientNetworkImage({
    super.key,
    required this.photoUrl,
    required this.photoPath,
    this.fit = BoxFit.cover,
    required this.fallback,
  });

  @override
  State<ResilientNetworkImage> createState() => _ResilientNetworkImageState();
}

class _ResilientNetworkImageState extends State<ResilientNetworkImage> {
  late final List<String> _candidates;
  int _index = 0;
  bool _switchScheduled = false;

  @override
  void initState() {
    super.initState();
    _candidates = _buildCandidates(widget.photoUrl, widget.photoPath);
  }

  @override
  Widget build(BuildContext context) {
    if (_candidates.isEmpty) {
      return widget.fallback;
    }

    final currentUrl = _candidates[_index];

    return CachedNetworkImage(
      key: ValueKey(currentUrl),
      imageUrl: currentUrl,
      fit: widget.fit,
      placeholder: (context, url) => Container(
        color: const Color(0xFFEFEAE2),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.6, color: AppTheme.primary),
        ),
      ),
      errorWidget: (context, url, error) {
        _switchToNextCandidate();
        return widget.fallback;
      },
    );
  }

  void _switchToNextCandidate() {
    if (_switchScheduled) return;
    if (_index >= _candidates.length - 1) return;

    _switchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _index += 1;
        _switchScheduled = false;
      });
    });
  }

  List<String> _buildCandidates(String rawUrl, String rawPath) {
    final out = <String>[];

    void add(String v) {
      final value = v.trim();
      if (value.isEmpty) return;
      if (out.contains(value)) return;
      out.add(value);
    }

    final normalizedUrl = _normalizeToApiBase(rawUrl);
    final normalizedPath = _normalizeToApiBase(rawPath);
    add(normalizedUrl);
    add(rawUrl);
    add(normalizedPath);

    return out;
  }

  String _normalizeToApiBase(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('uploads/')) {
      return '${ApiConfig.baseUrl}/$value';
    }

    if (value.startsWith('/uploads/')) {
      return '${ApiConfig.baseUrl}$value';
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      final normalizedPath =
          uri.path.startsWith('/') ? uri.path : '/${uri.path}';
      final query = uri.hasQuery ? '?${uri.query}' : '';

      if (normalizedPath.startsWith('/uploads/')) {
        return '${ApiConfig.baseUrl}$normalizedPath$query';
      }

      final localHost = uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '0.0.0.0';
      final dockerHost = !uri.host.contains('.') || uri.host.endsWith('.local');
      if (localHost || dockerHost) {
        return '${ApiConfig.baseUrl}$normalizedPath$query';
      }

      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiConfig.baseUrl}$value';
    }

    return '${ApiConfig.baseUrl}/$value';
  }
}
