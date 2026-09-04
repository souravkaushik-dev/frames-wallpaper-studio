import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dotty/models/fav_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator_master/palette_generator_master.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import '../Provider/theme_provider.dart';

/// Preview screen with a modern Material 3 / expressive bottom sheet.
///
/// The sheet deliberately does NOT use glassmorphism, BackdropFilter,
/// ImageFilter, or translucent blurred surfaces. It uses Material 3 surface
/// containers, tonal buttons, filled icon buttons, chips, cards and the
/// current ThemeData ColorScheme.
class PreviewScreen extends StatefulWidget {
final String imageUrl;
final String category;
final String? title;
final String? subtitle;

const PreviewScreen({
super.key,
required this.imageUrl,
required this.category,
this.title,
this.subtitle,
});

@override
State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
with SingleTickerProviderStateMixin {
late final AnimationController _introController;
late final ValueNotifier<double> _sheetExtent;

bool _isFavorite = false;
bool _favoriteLoading = false;
bool _isDownloading = false;
bool _isSettingWallpaper = false;

bool _metadataLoading = true;
bool _paletteLoading = true;

int? _imageWidth;
int? _imageHeight;
int? _fileSize;
String? _format;
List<Color> _palette = <Color>[];
Uint8List? _imageBytes;

String get _rawTitle {
final supplied = widget.title?.trim() ?? '';
if (supplied.isNotEmpty && supplied.toLowerCase() != 'wallpaper') {
return supplied;
}
return _titleFromUrl(widget.imageUrl);
}

/// Display rule requested for the app:
/// if a wallpaper name has more than two words, show only the first two.
String get _displayTitle {
final words = _rawTitle.trim().split(RegExp(r'\s+'));
if (words.length <= 2) return _rawTitle.trim();
return words.take(2).join(' ');
}

String? get _creator {
final category = widget.category.trim();
if (category.isEmpty) return null;
return category;
}

String get _host {
final host = Uri.tryParse(widget.imageUrl)?.host ?? '';
return host.replaceFirst(RegExp(r'^www\.'), '');
}

bool get _isDark => Theme.of(context).brightness == Brightness.dark;

ColorScheme get _scheme => Theme.of(context).colorScheme;

TextTheme get _text => GoogleFonts.googleSansFlexTextTheme(
Theme.of(context).textTheme,
);

String get _dimensions {
if (_imageWidth == null || _imageHeight == null) return 'Unknown';
return '${_imageWidth!} × ${_imageHeight!} px';
}

String get _resolution {
final w = _imageWidth;
final h = _imageHeight;
if (w == null || h == null) return 'Unknown';

final longEdge = math.max(w, h);
if (longEdge >= 7680) return '8K';
if (longEdge >= 5120) return '5K';
if (longEdge >= 3840) return '4K';
if (longEdge >= 2560) return '2K';
if (longEdge >= 1920) return 'FHD+';
if (longEdge >= 1280) return 'HD+';
return '${longEdge}px';
}

String get _aspectRatio {
final w = _imageWidth;
final h = _imageHeight;
if (w == null || h == null || w <= 0 || h <= 0) return 'Unknown';

final divisor = _gcd(w, h);
return '${w ~/ divisor}:${h ~/ divisor}';
}

@override
void initState() {
super.initState();

_introController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 520),
);

_sheetExtent = ValueNotifier<double>(.305);

_loadFavorite();
_analyzeImage();

WidgetsBinding.instance.addPostFrameCallback((_) {
if (!mounted) return;

SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
final dark = Theme.of(context).brightness == Brightness.dark;
SystemChrome.setSystemUIOverlayStyle(
SystemUiOverlayStyle(
statusBarColor: Colors.transparent,
systemNavigationBarColor: Colors.transparent,
statusBarIconBrightness:
dark ? Brightness.light : Brightness.dark,
systemNavigationBarIconBrightness:
dark ? Brightness.light : Brightness.dark,
),
);

_introController.forward();
});
}

@override
void dispose() {
_sheetExtent.dispose();
_introController.dispose();
super.dispose();
}

Future<void> _loadFavorite() async {
try {
final favorite = await FavoritesService.isFavorite(widget.imageUrl);
if (!mounted) return;
setState(() => _isFavorite = favorite);
} catch (e) {
debugPrint('Favorite load error: $e');
}
}

Future<void> _toggleFavorite() async {
if (_favoriteLoading) return;

setState(() => _favoriteLoading = true);
HapticFeedback.selectionClick();

try {
await FavoritesService.toggleFavorite(
imageUrl: widget.imageUrl,
category: widget.category,
);

if (!mounted) return;
setState(() => _isFavorite = !_isFavorite);
HapticFeedback.mediumImpact();
} catch (e) {
debugPrint('Favorite error: $e');
if (mounted) _showMessage('Could not update favorite', error: true);
} finally {
if (mounted) setState(() => _favoriteLoading = false);
}
}

Future<void> _analyzeImage() async {
final uri = Uri.tryParse(widget.imageUrl);

if (uri == null || !uri.hasScheme) {
if (!mounted) return;
setState(() {
_metadataLoading = false;
_paletteLoading = false;
});
return;
}

try {
final response = await http
    .get(
uri,
headers: const {'Accept': 'image/*'},
)
    .timeout(const Duration(seconds: 30));

if (response.statusCode < 200 || response.statusCode >= 300) {
throw HttpException('HTTP ${response.statusCode}');
}

final bytes = response.bodyBytes;
if (bytes.isEmpty) throw Exception('Empty image response');

_imageBytes = bytes;

final detectedFormat = _detectFormat(
bytes,
response.headers['content-type'],
);

ui.Codec? codec;
ui.Image? image;

try {
codec = await ui.instantiateImageCodec(bytes);
final frame = await codec.getNextFrame();
image = frame.image;

if (!mounted) return;

setState(() {
_imageWidth = image!.width;
_imageHeight = image.height;
_fileSize = bytes.length;
_format = detectedFormat;
_metadataLoading = false;
});

await _extractPalette(image);
} finally {
// dispose() is synchronous in Flutter.
codec?.dispose();
image?.dispose();
}
} catch (e, stack) {
debugPrint('Image analysis error: $e');
debugPrint('$stack');

if (!mounted) return;
setState(() {
_metadataLoading = false;
_paletteLoading = false;
});
}
}

Future<void> _extractPalette(ui.Image image) async {
try {
final generator = await PaletteGeneratorMaster.fromImage(
image,
maximumColorCount: 24,
colorSpace: ColorSpace.lab,
generateHarmony: false,
);

final candidates = generator.paletteColors
    .where((item) => item.population > 0)
    .map((item) => item.color)
    .toList();

final result = _uniqueColors(candidates, 6);

if (result.length >= 4) {
if (mounted) {
setState(() {
_palette = result;
_paletteLoading = false;
});
}
return;
}
} catch (e) {
debugPrint('LAB palette extraction error: $e');
}

try {
final generator = await PaletteGeneratorMaster.fromImage(
image,
maximumColorCount: 32,
colorSpace: ColorSpace.rgb,
generateHarmony: false,
);

final candidates = generator.paletteColors
    .where((item) => item.population > 0)
    .map((item) => item.color)
    .toList();

final result = _uniqueColors(candidates, 6);

if (result.length >= 4) {
if (mounted) {
setState(() {
_palette = result;
_paletteLoading = false;
});
}
return;
}
} catch (e) {
debugPrint('RGB palette extraction error: $e');
}

// Last-resort extraction directly from decoded pixels. This prevents the
// UI from being stuck at "no palette" for images the package cannot
// quantize successfully.
try {
final fallback = await _pixelPalette(image);

if (mounted) {
setState(() {
_palette = fallback;
_paletteLoading = false;
});
}
} catch (e) {
debugPrint('Pixel palette fallback error: $e');
if (mounted) setState(() => _paletteLoading = false);
}
}

Future<List<Color>> _pixelPalette(ui.Image image) async {
final data = await image.toByteData(
format: ui.ImageByteFormat.rawRgba,
);

if (data == null) return <Color>[];

final bytes = data.buffer.asUint8List();
final width = image.width;
final height = image.height;

// Keep the fallback inexpensive even for very large 4K/8K wallpapers.
final sampleCount = width * height;
final step = math.max(
1,
math.sqrt(sampleCount / 50000).ceil(),
);

final buckets = <int, int>{};

for (var y = 0; y < height; y += step) {
for (var x = 0; x < width; x += step) {
final index = (y * width + x) * 4;
if (index + 3 >= bytes.length) continue;

final r = bytes[index];
final g = bytes[index + 1];
final b = bytes[index + 2];
final a = bytes[index + 3];

if (a < 170) continue;

// 5 bits/channel = 32768 buckets, enough to keep visually different
// colors while remaining cheap.
final qr = r >> 3;
final qg = g >> 3;
final qb = b >> 3;
final key = (qr << 10) | (qg << 5) | qb;

buckets[key] = (buckets[key] ?? 0) + 1;
}
}

final ranked = buckets.entries.toList()
..sort((a, b) => b.value.compareTo(a.value));

final result = <Color>[];

for (final entry in ranked) {
final qr = (entry.key >> 10) & 31;
final qg = (entry.key >> 5) & 31;
final qb = entry.key & 31;

final color = Color.fromARGB(
255,
math.min(255, (qr << 3) + 4),
math.min(255, (qg << 3) + 4),
math.min(255, (qb << 3) + 4),
);

if (_usefulColor(color)) result.add(color);
if (result.length >= 12) break;
}

return _uniqueColors(result, 6);
}

List<Color> _uniqueColors(List<Color> colors, int maxCount) {
final result = <Color>[];

for (final color in colors) {
if (!_usefulColor(color)) continue;

final duplicate = result.any(
(existing) => _distance(existing, color) < 30,
);

if (!duplicate) result.add(color);
if (result.length >= maxCount) break;
}

return result;
}

bool _usefulColor(Color color) {
final hsl = HSLColor.fromColor(color);

// Reject only extreme near-black/near-white noise while keeping real
// dark AMOLED colors and pale wallpapers available.
return hsl.lightness > .025 && hsl.lightness < .985;
}

double _distance(Color a, Color b) {
final dr = a.red - b.red;
final dg = a.green - b.green;
final db = a.blue - b.blue;

return math.sqrt(dr * dr + dg * dg + db * db);
}

@override
Widget build(BuildContext context) {
context.watch<ThemeProvider>();

return Scaffold(
backgroundColor: Colors.black,
extendBodyBehindAppBar: true,
body: Stack(
fit: StackFit.expand,
children: [
_buildWallpaper(),
_buildWallpaperShade(),
_buildTopBar(),
_buildMaterialExpressiveSheet(),
],
),
);
}

Widget _buildWallpaper() {
return Positioned.fill(
child: Hero(
tag: widget.imageUrl,
child: Image.network(
widget.imageUrl,
fit: BoxFit.cover,
filterQuality: FilterQuality.high,
gaplessPlayback: true,
errorBuilder: (_, __, ___) {
return const ColoredBox(
color: Colors.black,
child: Center(
child: Icon(
Icons.image_not_supported_outlined,
color: Colors.white70,
size: 46,
),
),
);
},
loadingBuilder: (_, child, progress) {
if (progress == null) return child;

return const ColoredBox(
color: Colors.black,
child: Center(
child: CircularProgressIndicator(
color: Colors.white,
),
),
);
},
),
),
);
}

Widget _buildWallpaperShade() {
return Positioned.fill(
child: IgnorePointer(
child: DecoratedBox(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
stops: const [0, .16, .62, 1],
colors: [
Colors.black.withOpacity(.48),
Colors.transparent,
Colors.transparent,
Colors.black.withOpacity(.28),
],
),
),
),
),
);
}

Widget _buildTopBar() {
return Positioned(
top: 0,
left: 0,
right: 0,
child: SafeArea(
bottom: false,
child: Padding(
padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
child: FadeTransition(
opacity: CurvedAnimation(
parent: _introController,
curve: Curves.easeOut,
),
child: Align(
alignment: Alignment.topLeft,
child: _ReferenceBackButton(
onTap: () {
HapticFeedback.selectionClick();
Navigator.of(context).pop();
},
),
),
),
),
),
);
}

/// Main preview surface.
///
/// This intentionally stays very close to the supplied reference:
/// one large Material surface, large top corners, oversized typography,
/// two strong actions, then simple editorial sections below.
Widget _buildMaterialExpressiveSheet() {
final bottom = MediaQuery.paddingOf(context).bottom;

return DraggableScrollableSheet(
initialChildSize: .200,
minChildSize: .200,
maxChildSize: .94,
snap: true,
snapSizes: const [.205, .58, .94],
expand: false,
builder: (context, controller) {
return NotificationListener<DraggableScrollableNotification>(
onNotification: (notification) {
final extent = notification.extent;
if ((_sheetExtent.value - extent).abs() > .002) {
_sheetExtent.value = extent;
}
return false;
},
child: Material(
color: _scheme.surface,
elevation: 0,
clipBehavior: Clip.antiAlias,
borderRadius: BorderRadius.vertical(
top: Radius.circular(38.r),
),
child: ListView(
controller: controller,
physics: const ClampingScrollPhysics(),
padding: EdgeInsets.fromLTRB(
20.w,
9.h,
20.w,
math.max(28.h, bottom + 22.h),
),
children: [
_buildSheetHandle(),
SizedBox(height: 10.h),
_buildReferenceHeader(),
SizedBox(height: 13.h),
_buildReferenceActions(),
ValueListenableBuilder<double>(
valueListenable: _sheetExtent,
builder: (context, extent, _) {
final reveal = ((extent - .285) / .235).clamp(0.0, 1.0);

return ClipRect(
child: Align(
alignment: Alignment.topCenter,
heightFactor: reveal,
child: Opacity(
opacity: reveal,
child: Padding(
padding: EdgeInsets.only(top: 20.h),
child: _buildReferenceDetails(),
),
),
),
);
},
),
],
),
),
);
},
);
}

Widget _buildSheetHandle() {
return Center(
child: Container(
width: 36.w,
height: 4.h,
decoration: BoxDecoration(
color: _scheme.onSurfaceVariant.withOpacity(.32),
borderRadius: BorderRadius.circular(99.r),
),
),
);
}

Widget _buildReferenceHeader() {
return Row(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
_displayTitle.toLowerCase(),
maxLines: 1,
//   overflow: TextOverflow.ellipsis,
style: GoogleFonts.googleSansFlex(
fontSize: 25.sp,
fontWeight: FontWeight.w400,
letterSpacing: -.8,
height: 1.05,
color: _scheme.onSurface,
),
),
if (_creator != null) ...[
SizedBox(height: 6.h),
Text(
'By $_creator.',
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: GoogleFonts.googleSansFlex(
fontSize: 18.sp,
fontWeight: FontWeight.w300,
letterSpacing: -.2,
color: _scheme.onSurface,
),
),
],
],
),
),
SizedBox(width: 8.w),
_FavoriteButton(
selected: _isFavorite,
loading: _favoriteLoading,
onTap: _toggleFavorite,
color: _scheme.primary,
),
],
);
}

Color get _wallpaperAccent {
if (_palette.isEmpty) return _scheme.primary;

final ranked = [..._palette]
..sort((a, b) {
final ah = HSLColor.fromColor(a);
final bh = HSLColor.fromColor(b);

final ascore = ah.saturation * .70 +
(1 - (ah.lightness - .50).abs()) * .30;
final bscore = bh.saturation * .70 +
(1 - (bh.lightness - .50).abs()) * .30;

return bscore.compareTo(ascore);
});

return ranked.first;
}

Color _expressiveButtonColor() {
final hsl = HSLColor.fromColor(_wallpaperAccent);

// Material 3 expressive: preserve wallpaper hue while constraining
// saturation/lightness to comfortable button tones.
final lightness = (_isDark
? hsl.lightness.clamp(.34, .62)
    : hsl.lightness.clamp(.30, .56)).toDouble();

final saturation = hsl.saturation.clamp(.42, .82).toDouble();

return hsl
    .withLightness(lightness)
    .withSaturation(saturation)
    .toColor();
}

Color _contrastingForeground(Color background) {
return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
? Colors.white
    : Colors.black;
}

Color _downloadButtonColor(Color accent) {
final hsl = HSLColor.fromColor(accent);

// Both modes derive from the wallpaper; dark mode simply gets a deeper
// tonal value so the button remains comfortable on a dark surface.
final lightness = _isDark ? .20 : .18;
final saturation = (hsl.saturation * .48).clamp(.10, .42).toDouble();

return hsl
    .withLightness(lightness)
    .withSaturation(saturation)
    .toColor();
}


Widget _buildReferenceActions() {
final accent = _expressiveButtonColor();
final downloadColor = _downloadButtonColor(accent);

return Row(
children: [
Expanded(
child: _ReferenceActionButton(
label: 'Download',
filledColor: downloadColor,
foregroundColor: _contrastingForeground(downloadColor),
loading: _isDownloading,
onTap: _isDownloading ? null : _downloadWallpaper,
),
),
SizedBox(width: 14.w),
Expanded(
child: _ReferenceActionButton(
label: 'Apply',
filledColor: accent,
foregroundColor: _contrastingForeground(accent),
loading: _isSettingWallpaper,
onTap: _isSettingWallpaper ? null : _showApplyOptions,
),
),
],
);
}

Widget _buildReferenceDetails() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildReferenceSectionHeading(
icon: Hicons.informationSquareLightOutline,
title: 'info',
),
SizedBox(height: 18.h),
_buildReferenceInfo(),

SizedBox(height: 36.h),

_buildReferenceSectionHeading(
icon: Hicons.paletteLightOutline,
title: 'colors',
),
SizedBox(height: 5.h),
Padding(
padding: EdgeInsets.only(left: 48.w),
child: Text(
'Tap swatches to copy',
style: _text.bodyMedium?.copyWith(
color: _scheme.onSurfaceVariant.withOpacity(.58),
fontSize: 14.sp,
),
),
),
SizedBox(height: 3.h),
_buildPalette(),

SizedBox(height: 36.h),

_buildReferenceSectionHeading(
icon: Hicons.linkLightOutline,
title: 'source',
),
SizedBox(height: 14.h),
_buildInlineSourceCard(),
],
);
}


Widget _buildReferenceSectionHeading({
required IconData icon,
required String title,
}) {
return Row(
children: [
Icon(
icon,
size: 28.sp,
color: _scheme.onSurface,
),
SizedBox(width: 14.w),
Text(
title,
style: _text.headlineSmall?.copyWith(
fontSize: 28.sp,
fontWeight: FontWeight.w300,
letterSpacing: -.45,
height: 1,
color: _scheme.onSurface,
),
),
],
);
}

Widget _buildReferenceInfo() {
final loading = _metadataLoading;

return Padding(
padding: EdgeInsets.only(left: 48.w),
child: Column(
children: [
_referenceInfoRow(
'Collection',
widget.category.trim().isEmpty ? 'Unknown' : widget.category,
),
SizedBox(height: 20.h),
_referenceInfoRow(
'Dimensions',
loading ? 'Loading…' : _dimensions,
),
SizedBox(height: 20.h),
_referenceInfoRow(
'Resolution',
loading ? 'Loading…' : _resolution,
),
SizedBox(height: 20.h),
_referenceInfoRow(
'Aspect ratio',
loading ? 'Loading…' : _aspectRatio,
),
SizedBox(height: 20.h),
_referenceInfoRow(
'File size',
loading ? 'Loading…' : _formatBytes(_fileSize ?? 0),
),
SizedBox(height: 20.h),
_referenceInfoRow(
'License',
'Not provided by API',
multiline: true,
),
],
),
);
}

Widget _referenceInfoRow(
String label,
String value, {
bool multiline = false,
}) {
return Row(
crossAxisAlignment:
multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
children: [
SizedBox(
width: 145.w,
child: Text(
'$label :',
style: _text.titleMedium?.copyWith(
fontSize: 16.sp,
fontWeight: FontWeight.w400,
height: 1.35,
color: _scheme.onSurface,
),
),
),
Expanded(
child: Text(
value,
maxLines: multiline ? 4 : 2,
overflow: TextOverflow.ellipsis,
style: _text.titleMedium?.copyWith(
fontSize: 16.sp,
fontWeight: FontWeight.w400,
height: 1.42,
color: _scheme.onSurface,
),
),
),
],
);
}

Widget _buildPalette() {
if (_paletteLoading) {
return SizedBox(
height: 142.h,
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SizedBox(
width: 23.w,
height: 23.w,
child: CircularProgressIndicator(
strokeWidth: 2.2,
color: _scheme.primary,
),
),
SizedBox(height: 9.h),
Text(
'Extracting colors…',
style: _text.bodyMedium?.copyWith(
color: _scheme.onSurfaceVariant,
),
),
],
),
),
);
}

if (_palette.isEmpty) {
return Material(
color: _scheme.surfaceContainerLow,
borderRadius: BorderRadius.circular(20.r),
child: Padding(
padding: EdgeInsets.all(16.w),
child: Text(
'No usable palette was found in this image.',
style: _text.bodyMedium?.copyWith(
color: _scheme.onSurfaceVariant,
),
),
),
);
}

return GridView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: _palette.length,
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 3,
mainAxisSpacing: 12.h,
crossAxisSpacing: 12.w,
childAspectRatio: 2.35,
),
itemBuilder: (_, index) {
final color = _palette[index];
return _ReferencePalette(
color: color,
hex: _hex(color),
onTap: () => _copyHex(color),
);
},
);
}

Widget _buildInlineSourceCard() {
return Material(
color: _scheme.surfaceContainerLow,
borderRadius: BorderRadius.circular(20.r),
clipBehavior: Clip.antiAlias,
child: Padding(
padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
child: Row(
children: [
Expanded(
child: Text(
widget.imageUrl,
maxLines: 3,
overflow: TextOverflow.ellipsis,
style: _text.bodyMedium?.copyWith(
color: _scheme.onSurfaceVariant,
height: 1.35,
),
),
),
IconButton(
tooltip: 'Copy source URL',
onPressed: () =>
_copyText(widget.imageUrl, 'Source URL copied'),
icon: const Icon(Icons.copy_rounded),
),
],
),
),
);
}

Future<void> _showApplyOptions() async {
if (_isSettingWallpaper) return;

HapticFeedback.selectionClick();

final location = await showModalBottomSheet<int>(
context: context,
isScrollControlled: true,
useSafeArea: true,
backgroundColor: _scheme.surface,
elevation: 0,
showDragHandle: false,
barrierColor: Colors.black.withOpacity(.52),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.vertical(
top: Radius.circular(38.r),
),
),
builder: (sheetContext) {
final sheetScheme = Theme.of(sheetContext).colorScheme;
final sheetText = Theme.of(sheetContext).textTheme;

return SafeArea(
top: false,
child: Padding(
padding: EdgeInsets.fromLTRB(26.w, 12.h, 26.w, 18.h),
child: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 42.w,
height: 4.h,
decoration: BoxDecoration(
color: sheetScheme.onSurfaceVariant.withOpacity(.48),
borderRadius: BorderRadius.circular(99.r),
),
),
SizedBox(height: 30.h),
Text(
'Apply Wallpaper To',
textAlign: TextAlign.center,
style: GoogleFonts.googleSansFlex(
fontSize: 29.sp,
fontWeight: FontWeight.w500,
letterSpacing: -.65,
height: 1.05,
color: sheetScheme.onSurface,
),
),
SizedBox(height: 24.h),
Padding(
padding: EdgeInsets.symmetric(horizontal: 20.w),
child: Text(
'You can apply wallpaper to particular screens or '
'apply wallpaper to both screens.',
textAlign: TextAlign.center,
style: GoogleFonts.googleSansFlex(
fontSize: 16.sp,
height: 1.6,
color: sheetScheme.onSurface,
),
),
),
SizedBox(height: 28.h),

_ReferenceApplyOption(
title: 'Apply using other apps',
outlined: true,
onTap: () {
Navigator.of(sheetContext).pop();
_copyText(
widget.imageUrl,
'Wallpaper source copied',
);
},
),
SizedBox(height: 10.h),

_ReferenceApplyOption(
title: 'Home Screen',
outlined: true,
onTap: () => Navigator.of(sheetContext)
    .pop(WallpaperManagerPlus.homeScreen),
),
SizedBox(height: 10.h),

_ReferenceApplyOption(
title: 'Lock Screen',
outlined: true,
onTap: () => Navigator.of(sheetContext)
    .pop(WallpaperManagerPlus.lockScreen),
),
SizedBox(height: 10.h),

_ReferenceApplyOption(
title: 'Home and lock screen',
outlined: false,
fillColor: _expressiveButtonColor(),
onTap: () => Navigator.of(sheetContext)
    .pop(WallpaperManagerPlus.bothScreens),
),
],
),
),
),
);
},
);

if (location == null || !mounted) return;

final locationName = switch (location) {
WallpaperManagerPlus.homeScreen => 'Home screen',
WallpaperManagerPlus.lockScreen => 'Lock screen',
_ => 'Home + Lock screen',
};

await _applyWallpaper(location, locationName);
}

Future<void> _showCopiedSourceMessage() async {
await _copyText(widget.imageUrl, 'Wallpaper source copied');
}

void _showMessage(String message, {bool error = false}) {
if (!mounted) return;

final scheme = _scheme;

ScaffoldMessenger.of(context)
..hideCurrentSnackBar()
..showSnackBar(
SnackBar(
behavior: SnackBarBehavior.floating,
backgroundColor: error
? scheme.errorContainer
    : scheme.inverseSurface,
margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20.r),
),
content: Row(
children: [
Icon(
error
? Icons.error_outline_rounded
    : Icons.check_circle_outline_rounded,
color: error
? scheme.onErrorContainer
    : scheme.onInverseSurface,
size: 19.sp,
),
SizedBox(width: 9.w),
Expanded(
child: Text(
message,
style: _text.bodyMedium?.copyWith(
color: error
? scheme.onErrorContainer
    : scheme.onInverseSurface,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
);
}
Future<void> _applyWallpaper(int location, String locationName) async {
if (_isSettingWallpaper) return;

final uri = Uri.tryParse(widget.imageUrl);
if (uri == null || !uri.hasScheme) {
_showMessage('Invalid wallpaper URL', error: true);
return;
}

setState(() => _isSettingWallpaper = true);
HapticFeedback.mediumImpact();

File? file;

try {
final bytes = await _getImageBytes();
if (bytes.isEmpty) throw Exception('Empty wallpaper image');

final directory = await getTemporaryDirectory();
final format = _format ?? _detectFormat(bytes, null);

file = File(
'${directory.path}/dotty_wallpaper_'
'${DateTime.now().microsecondsSinceEpoch}.'
'${_extensionFromFormat(format)}',
);

await file.writeAsBytes(bytes, flush: true);

await WallpaperManagerPlus()
    .setWallpaper(file, location)
    .timeout(const Duration(seconds: 30));

if (mounted) {
HapticFeedback.heavyImpact();
_showMessage('$locationName wallpaper applied');
}
} on TimeoutException {
if (mounted) {
_showMessage('Wallpaper operation timed out', error: true);
}
} on SocketException {
if (mounted) {
_showMessage('Could not download wallpaper', error: true);
}
} catch (e, stack) {
debugPrint('Wallpaper error: $e');
debugPrint('$stack');
if (mounted) {
_showMessage('Could not set wallpaper', error: true);
}
} finally {
try {
if (file != null && await file.exists()) {
await file.delete();
}
} catch (e) {
debugPrint('Wallpaper cleanup error: $e');
}

if (mounted) setState(() => _isSettingWallpaper = false);
}
}

Future<void> _downloadWallpaper() async {
if (_isDownloading) return;

setState(() => _isDownloading = true);
HapticFeedback.mediumImpact();

try {
final bytes = await _getImageBytes();
if (bytes.isEmpty) throw Exception('Empty wallpaper image');

final result = await ImageGallerySaverPlus.saveImage(
bytes,
quality: 100,
name: 'dotty_wallpaper_${DateTime.now().millisecondsSinceEpoch}',
);

debugPrint('ImageGallerySaverPlus result: $result');

final success = result['isSuccess'] == true ||
result['filePath'] != null ||
result['savedFilePath'] != null;

if (!success) {
throw Exception('Gallery save failed: $result');
}

if (mounted) {
HapticFeedback.heavyImpact();
_showMessage('Wallpaper saved to gallery');
}
} on TimeoutException {
if (mounted) _showMessage('Download timed out', error: true);
} catch (e, stack) {
debugPrint('Download error: $e');
debugPrint('$stack');
if (mounted) _showMessage('Could not save wallpaper', error: true);
} finally {
if (mounted) setState(() => _isDownloading = false);
}
}

Future<Uint8List> _getImageBytes() async {
final cached = _imageBytes;
if (cached != null && cached.isNotEmpty) return cached;

final uri = Uri.tryParse(widget.imageUrl);
if (uri == null || !uri.hasScheme) {
throw Exception('Invalid wallpaper URL');
}

final response = await http
    .get(
uri,
headers: const {'Accept': 'image/*'},
)
    .timeout(const Duration(seconds: 30));

if (response.statusCode < 200 || response.statusCode >= 300) {
throw HttpException('Download failed: ${response.statusCode}');
}

if (response.bodyBytes.isEmpty) {
throw Exception('Empty image response');
}

_imageBytes = response.bodyBytes;
return response.bodyBytes;
}

Future<void> _copyHex(Color color) async {
final hex = _hex(color);
await Clipboard.setData(ClipboardData(text: hex));
HapticFeedback.selectionClick();

if (mounted) _showMessage('$hex copied');
}

Future<void> _copyText(String value, String message) async {
await Clipboard.setData(ClipboardData(text: value));
HapticFeedback.selectionClick();

if (mounted) _showMessage(message);
}


String _hex(Color color) {
final r = color.red.toRadixString(16).padLeft(2, '0');
final g = color.green.toRadixString(16).padLeft(2, '0');
final b = color.blue.toRadixString(16).padLeft(2, '0');
return '#$r$g$b'.toUpperCase();
}

String _formatBytes(int bytes) {
if (bytes <= 0) return 'Unknown';

const units = <String>['B', 'KB', 'MB', 'GB'];
var value = bytes.toDouble();
var index = 0;

while (value >= 1024 && index < units.length - 1) {
value /= 1024;
index++;
}

if (index == 0) return '${value.round()} ${units[index]}';

final decimals = value >= 100 ? 0 : 1;
return '${value.toStringAsFixed(decimals)} ${units[index]}';
}

String _detectFormat(Uint8List bytes, String? contentType) {
final type = contentType?.split(';').first.trim().toLowerCase();

switch (type) {
case 'image/jpeg':
case 'image/jpg':
return 'JPEG';
case 'image/png':
return 'PNG';
case 'image/webp':
return 'WEBP';
case 'image/gif':
return 'GIF';
case 'image/avif':
return 'AVIF';
case 'image/heic':
case 'image/heif':
return 'HEIC';
}

if (bytes.length >= 8 &&
bytes[0] == 0x89 &&
bytes[1] == 0x50 &&
bytes[2] == 0x4E &&
bytes[3] == 0x47) {
return 'PNG';
}

if (bytes.length >= 3 &&
bytes[0] == 0xFF &&
bytes[1] == 0xD8 &&
bytes[2] == 0xFF) {
return 'JPEG';
}

if (bytes.length >= 12 &&
bytes[0] == 0x52 &&
bytes[1] == 0x49 &&
bytes[2] == 0x46 &&
bytes[3] == 0x46 &&
bytes[8] == 0x57 &&
bytes[9] == 0x45 &&
bytes[10] == 0x42 &&
bytes[11] == 0x50) {
return 'WEBP';
}

final path = Uri.tryParse(widget.imageUrl)?.path.toLowerCase() ?? '';

if (path.endsWith('.png')) return 'PNG';
if (path.endsWith('.webp')) return 'WEBP';
if (path.endsWith('.gif')) return 'GIF';
if (path.endsWith('.avif')) return 'AVIF';
if (path.endsWith('.heic') || path.endsWith('.heif')) return 'HEIC';

return 'JPEG';
}

String _extensionFromFormat(String format) {
switch (format.toUpperCase()) {
case 'PNG':
return 'png';
case 'WEBP':
return 'webp';
case 'GIF':
return 'gif';
case 'AVIF':
return 'avif';
case 'HEIC':
return 'heic';
default:
return 'jpg';
}
}

int _gcd(int a, int b) {
while (b != 0) {
final temp = a % b;
a = b;
b = temp;
}
return a.abs();
}

String _titleFromUrl(String url) {
var name = Uri.tryParse(url)?.pathSegments.last ?? '';

if (name.isEmpty) return 'Wallpaper';

name = name.replaceFirst(
RegExp(
r'\.(jpg|jpeg|png|webp|gif|avif|heic|heif)$',
caseSensitive: false,
),
'',
);

// Remove common resolution suffixes such as -3840x2160.
name = name.replaceFirst(
RegExp(r'-\d+x\d+(?:-\d+)?$'),
'',
);

name = name.replaceAll(RegExp(r'[_-]+'), ' ').trim();

if (name.isEmpty) return 'Wallpaper';

return name
    .split(RegExp(r'\s+'))
    .map(
(word) => word.isEmpty
? word
    : '${word[0].toUpperCase()}${word.substring(1)}',
)
    .join(' ');
}
}


class _ReferenceBackButton extends StatelessWidget {
final VoidCallback onTap;

const _ReferenceBackButton({required this.onTap});

@override
Widget build(BuildContext context) {
return Semantics(
button: true,
label: 'Back',
child: GestureDetector(
behavior: HitTestBehavior.opaque,
onTap: onTap,
child: SizedBox(
width: 46.w,
height: 46.w,
child: Align(
alignment: Alignment.centerLeft,
child: Icon(
Hicons.left2LightOutline,
color: Colors.white,
size: 22.sp,
),
),
),
),
);
}
}

class _FavoriteButton extends StatelessWidget {
final bool selected;
final bool loading;
final VoidCallback onTap;
final Color color;

const _FavoriteButton({
required this.selected,
required this.loading,
required this.onTap,
required this.color,
});

@override
Widget build(BuildContext context) {
return Semantics(
button: true,
label: selected ? 'Remove favorite' : 'Add favorite',
child: Material(
color: Colors.transparent,
shape: const CircleBorder(),
child: InkWell(
customBorder: const CircleBorder(),
onTap: loading ? null : onTap,
child: SizedBox(
width: 56.w,
height: 56.w,
child: Center(
child: AnimatedSwitcher(
duration: const Duration(milliseconds: 220),
switchInCurve: Curves.easeOutBack,
switchOutCurve: Curves.easeIn,
child: loading
? SizedBox(
key: const ValueKey('loading'),
width: 21.w,
height: 21.w,
child: CircularProgressIndicator(
strokeWidth: 2.2,
color: color,
),
)
    : Icon(
key: ValueKey(selected),
selected
? Hicons.heart3Bold
    : Hicons.heart3LightOutline,
size: 31.sp,
color: color,
),
),
),
),
),
),
);
}
}

class _ReferenceActionButton extends StatelessWidget {
final String label;
final Color filledColor;
final Color foregroundColor;
final bool loading;
final VoidCallback? onTap;

const _ReferenceActionButton({
required this.label,
required this.filledColor,
required this.foregroundColor,
required this.loading,
required this.onTap,
});

@override
Widget build(BuildContext context) {
return Material(
color: filledColor,
borderRadius: BorderRadius.circular(20.r),
clipBehavior: Clip.antiAlias,
child: InkWell(
onTap: onTap,
child: SizedBox(
height: 58.h,
child: Center(
child: AnimatedSwitcher(
duration: const Duration(milliseconds: 180),
child: loading
? SizedBox(
key: const ValueKey('loading'),
width: 21.w,
height: 21.w,
child: CircularProgressIndicator(
strokeWidth: 2.2,
color: foregroundColor,
),
)
    : Text(
label,
key: ValueKey(label),
style: GoogleFonts.googleSansFlex(
fontSize: 16.sp,
fontWeight: FontWeight.w500,
color: foregroundColor,
),
),
),
),
),
),
);
}
}

class _ReferenceApplyOption extends StatelessWidget {
final String title;
final bool outlined;
final VoidCallback onTap;
final Color? fillColor;

const _ReferenceApplyOption({
required this.title,
required this.outlined,
required this.onTap,
this.fillColor,
});

@override
Widget build(BuildContext context) {
final scheme = Theme.of(context).colorScheme;

return Material(
color: outlined ? scheme.surface : (fillColor ?? scheme.primary),
borderRadius: BorderRadius.circular(22.r),
clipBehavior: Clip.antiAlias,
child: InkWell(
onTap: onTap,
child: Container(
height: 78.h,
width: double.infinity,
alignment: Alignment.center,
decoration: outlined
? BoxDecoration(
border: Border.all(
color: scheme.primary.withOpacity(.82),
width: 1.5,
),
borderRadius: BorderRadius.circular(22.r),
)
    : null,
child: Text(
title,
textAlign: TextAlign.center,
style: GoogleFonts.googleSansFlex(
fontSize: 18.sp,
fontWeight: FontWeight.w400,
color: outlined ? scheme.onSurface : scheme.onPrimary,
),
),
),
),
);
}
}

class _ReferencePalette extends StatelessWidget {
final Color color;
final String hex;
final VoidCallback onTap;

const _ReferencePalette({
required this.color,
required this.hex,
required this.onTap,
});

@override
Widget build(BuildContext context) {
final foreground =
ThemeData.estimateBrightnessForColor(color) == Brightness.dark
? Colors.white
    : Colors.black;

return Material(
color: color,
borderRadius: BorderRadius.circular(28.r),
clipBehavior: Clip.antiAlias,
child: InkWell(
onTap: onTap,
child: Center(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 8.w),
child: Text(
hex,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: TextStyle(
color: foreground.withOpacity(.55),
fontSize: 13.sp,
fontWeight: FontWeight.w700,
letterSpacing: .05,
),
),
),
),
),
);
}
}