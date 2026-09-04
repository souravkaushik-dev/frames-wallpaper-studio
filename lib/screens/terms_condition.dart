import 'package:dotty/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({
    super.key,
  });

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _primary(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
  }

  Color _secondary(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;
  }

  Color _muted(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkMuted
        : AppColors.lightMuted;
  }

  Color _divider(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkDivider
        : AppColors.lightDivider;
  }

  @override
  Widget build(BuildContext context) {
    final background = _background(context);
    final primary = _primary(context);
    final secondary = _secondary(context);
    final muted = _muted(context);
    final divider = _divider(context);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  18.h,
                  20.w,
                  0,
                ),
                child: _PlainBackButton(
                  color: primary,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  67.h,
                  20.w,
                  0,
                ),
                child: Text(
                  'Terms',
                  style: GoogleFonts.googleSansFlex(
                    color: primary,
                    fontSize: 43.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.05,
                    letterSpacing: -.7,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  20.h,
                  20.w,
                  42.h,
                ),
                child: Text(
                  'Simple guidelines for using Frames responsibly',
                  style: GoogleFonts.googleSansFlex(
                    color: muted.withOpacity(.72),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TermsSectionPlain(
                    number: '01',
                    title: 'Wallpaper Usage',
                    body:
                    'Wallpapers available inside Frames are intended for '
                        'personal use and visual customization purposes. Users '
                        'are responsible for respecting original creators and '
                        'external content sources where applicable.',
                    primary: primary,
                    secondary: secondary,
                    muted: muted,
                    divider: divider,
                  ),
                  SizedBox(height: 38.h),
                  _TermsSectionPlain(
                    number: '02',
                    title: 'Content Sources',
                    body:
                    'Frames aggregates wallpapers from APIs and publicly '
                        'available platforms to provide a seamless browsing '
                        'experience. We do not claim ownership of every image '
                        'displayed inside the application.',
                    primary: primary,
                    secondary: secondary,
                    muted: muted,
                    divider: divider,
                  ),
                  SizedBox(height: 38.h),
                  _TermsSectionPlain(
                    number: '03',
                    title: 'Application Experience',
                    body:
                    'Users agree to use the application responsibly and '
                        'avoid misuse, reverse engineering, automated scraping, '
                        'or actions that may harm platform performance.',
                    primary: primary,
                    secondary: secondary,
                    muted: muted,
                    divider: divider,
                  ),
                  SizedBox(height: 38.h),
                  _TermsSectionPlain(
                    number: '04',
                    title: 'Updates & Changes',
                    body:
                    'Features, interface design, policies, and services may '
                        'evolve over future versions of Frames without prior '
                        'notice in order to improve the user experience.',
                    primary: primary,
                    secondary: secondary,
                    muted: muted,
                    divider: divider,
                  ),
                  SizedBox(height: 38.h),
                  _TermsSectionPlain(
                    number: '05',
                    title: 'Acceptance',
                    body:
                    'By using Frames, users acknowledge and accept these '
                        'terms and conditions as part of the platform experience.',
                    primary: primary,
                    secondary: secondary,
                    muted: muted,
                    divider: divider,
                  ),
                  SizedBox(height: 55.h),
                  Container(
                    height: 1,
                    color: divider.withOpacity(.6),
                  ),
                  SizedBox(height: 17.h),
                  Text(
                    'BUILT FOR BETTER SCREENS',
                    style: GoogleFonts.roboto(
                      color: muted.withOpacity(.45),
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 65.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSectionPlain extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color divider;

  const _TermsSectionPlain({
    required this.number,
    required this.title,
    required this.body,
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              number,
              style: GoogleFonts.googleSansFlex(
                color: muted.withOpacity(.65),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: -.1,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.googleSansFlex(
                  color: primary,
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  letterSpacing: -.2,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 13.h),
        Padding(
          padding: EdgeInsets.only(left: 31.w),
          child: Text(
            body,
            style: GoogleFonts.roboto(
              color: secondary.withOpacity(.78),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              height: 1.65,
            ),
          ),
        ),
        SizedBox(height: 28.h),
        Container(
          height: 1,
          color: divider.withOpacity(.55),
        ),
      ],
    );
  }
}

class _PlainBackButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const _PlainBackButton({
    required this.color,
    required this.onTap,
  });

  @override
  State<_PlainBackButton> createState() => _PlainBackButtonState();
}

class _PlainBackButtonState extends State<_PlainBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .88 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Hicons.left2LightOutline,
              color: widget.color,
              size: 22.sp,
            ),
          ),
        ),
      ),
    );
  }
}
