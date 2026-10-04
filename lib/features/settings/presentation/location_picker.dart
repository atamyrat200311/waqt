import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/dimens.dart';
import '../../../data/settings/app_settings.dart';
import '../../../data/settings/settings_controller.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/layout.dart';
import '../../../shared/widgets/waqt_card.dart';
import '../../../shared/widgets/waqt_icon.dart';
import '../../notifications/application/notification_service.dart';
import '../../prayer/location/city_catalog.dart';
import '../../prayer/location/location_service.dart';

/// Picked location plus the bundled city (for the method preset), if any.
typedef LocationPicked = void Function(SavedLocation location, {String? countryCode});

/// GPS button, city search and manual coordinates. No network.
class LocationPicker extends ConsumerStatefulWidget {
  const LocationPicker({super.key, required this.onPicked, this.shrinkWrap = false});

  final LocationPicked onPicked;
  final bool shrinkWrap;

  @override
  ConsumerState<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends ConsumerState<LocationPicker> {
  final _query = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _name = TextEditingController();
  bool _locating = false;
  String? _error;
  bool _manual = false;

  @override
  void dispose() {
    _query.dispose();
    _lat.dispose();
    _lng.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _useGps() async {
    final l = context.l10n;
    setState(() {
      _locating = true;
      _error = null;
    });
    final r = await ref.read(locationServiceProvider).current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (r.location != null) {
      final catalog = await ref.read(cityCatalogProvider.future);
      final near = catalog.nearest(r.location!.latitude, r.location!.longitude);
      widget.onPicked(r.location!, countryCode: near != null && near.$2 < 300 ? near.$1.countryCode : null);
    } else {
      setState(() => _error = switch (r.failure!) {
            LocationFailure.denied || LocationFailure.deniedForever => l.locationDenied,
            _ => l.locationFailed,
          });
    }
  }

  void _pickCity(City c) => widget.onPicked(
        SavedLocation(
          latitude: c.latitude,
          longitude: c.longitude,
          name: c.name,
          timezone: c.timezone,
          manual: true,
        ),
        countryCode: c.countryCode,
      );

  Future<void> _saveCoordinates() async {
    final l = context.l10n;
    final lat = double.tryParse(_lat.text.replaceAll(',', '.'));
    final lng = double.tryParse(_lng.text.replaceAll(',', '.'));
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) {
      setState(() => _error = l.locationInvalid);
      return;
    }
    final catalog = await ref.read(cityCatalogProvider.future);
    final tz = await LocationService.deviceTimezone();
    final name = _name.text.trim().isEmpty ? LocationService.displayName(catalog, lat, lng) : _name.text.trim();
    widget.onPicked(
      SavedLocation(latitude: lat, longitude: lng, name: name, timezone: tz, manual: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = context.l10n;
    final catalog = ref.watch(cityCatalogProvider).value;
    final results = catalog?.search(_query.text, limit: 40) ?? const <City>[];
    final current = ref.watch(settingsProvider.select((s) => s.location));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillButton(
          label: _locating ? l.locationLocating : l.locationUseCurrent,
          icon: WaqtIcons.locate,
          height: 52,
          radius: 16,
          expand: true,
          onPressed: _locating ? null : _useGps,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(_error!, style: WaqtType.sans(14, weight: 600, color: c.brassText)),
          ),
        ],
        const SizedBox(height: 14),
        TextField(
          controller: _query,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          style: WaqtType.sans(16, color: c.ink),
          decoration: InputDecoration(
            hintText: l.locationSearch,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: WaqtIcon(WaqtIcons.pin, size: 18, color: c.muted),
            ),
            filled: true,
            fillColor: c.fill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 10),
        WaqtGroup(
          radius: Radii.listGroup,
          children: [
            for (final city in results)
              InkWell(
                onTap: () => _pickCity(city),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(city.name, style: WaqtType.sans(16, weight: 600, color: c.ink)),
                        ),
                        Text(city.countryCode, style: WaqtType.sans(13, color: c.muted)),
                        if (current?.name == city.name && current?.manual == true) ...[
                          const SizedBox(width: 8),
                          WaqtIcon(WaqtIcons.check, size: 18, color: c.accent),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _manual = !_manual),
          child: Text(l.locationCoordinates, style: WaqtType.sans(15, weight: 600, color: c.accent)),
        ),
        if (_manual)
          WaqtCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lat,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(labelText: l.locationLatitude),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _lng,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(labelText: l.locationLongitude),
                      ),
                    ),
                  ],
                ),
                TextField(controller: _name, decoration: InputDecoration(labelText: l.locationName)),
                const SizedBox(height: 14),
                BigButton(label: l.save, onPressed: _saveCoordinates),
              ],
            ),
          ),
        const SizedBox(height: 14),
        Text(l.locationPrivacy, textAlign: TextAlign.center, style: WaqtType.sans(13, color: c.muted, height: 1.5)),
      ],
    );
  }
}

/// Settings → Location.
class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final loc = ref.watch(settingsProvider.select((s) => s.effectiveLocation));
    return SubScreen(
      title: l.locationTitle,
      backLabel: l.back,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.title, 6, Gap.title, 0),
            child: Row(
              children: [
                WaqtIcon(WaqtIcons.pin, size: 16, color: c.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${displayPlaceName(loc.name, l)} · ${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}',
                    style: WaqtType.sans(14, color: c.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(Gap.screen, 18, Gap.screen, 0),
          sliver: SliverToBoxAdapter(
            child: LocationPicker(
              onPicked: (picked, {countryCode}) async {
                await ref.read(settingsProvider.notifier).setLocation(picked);
                if (context.mounted) await Navigator.of(context).maybePop();
              },
            ),
          ),
        ),
      ],
    );
  }
}
