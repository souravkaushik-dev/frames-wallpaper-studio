import 'dart:ui';

import 'package:dotty/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({
    super.key,
  });

  // ============================================================
  // THEME
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkBackground
        : AppColors.lightBackground;
  }

  Color _surface(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSurface
        : AppColors.lightSurface;
  }

  Color _surfaceSoft(BuildContext context) {
    return _isDark(context)
        ? AppColors.darkSurfaceSoft
        : AppColors.lightSurfaceSoft;
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

  Color get _accent => AppColors.accent;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final background =
    _background(context);

    final surface =
    _surface(context);

    final surfaceSoft =
    _surfaceSoft(context);

    final text =
    _primary(context);

    final secondary =
    _secondary(context);

    final muted =
    _muted(context);

    final divider =
    _divider(context);

    return Scaffold(
      backgroundColor:
      background,

      body:
      SafeArea(
        child:
        CustomScrollView(
          physics:
          const BouncingScrollPhysics(
            parent:
            AlwaysScrollableScrollPhysics(),
          ),

          slivers: [
            // ======================================================
            // HEADER
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20.w,
                  16.h,
                  20.w,
                  0,
                ),

                child:
                Row(
                  children: [
                    _BackButton(
                      text:
                      text,

                      accent:
                      _accent,

                      surface:
                      surface,

                      divider:
                      divider,
                    ),

                    SizedBox(
                      width:
                      16.w,
                    ),

                    Expanded(
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Text(
                            'FRAMES',

                            style:
                            GoogleFonts.inter(
                              color:
                              secondary,

                              fontSize:
                              8.sp,

                              fontWeight:
                              FontWeight.w800,

                              letterSpacing:
                              2.1,
                            ),
                          ),

                          SizedBox(
                            height:
                            3.h,
                          ),

                          Text(
                            'Privacy',

                            style:
                            GoogleFonts.inter(
                              color:
                              text,

                              fontSize:
                              23.sp,

                              fontWeight:
                              FontWeight.w800,

                              letterSpacing:
                              -.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _HeaderBadge(
                      accent:
                      _accent,

                      text:
                      text,

                      divider:
                      divider,
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // HERO
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  22.w,
                  42.h,
                  22.w,
                  30.h,
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    // Small eyebrow
                    Row(
                      children: [
                        Container(
                          width:
                          7.w,

                          height:
                          7.w,

                          decoration:
                          BoxDecoration(
                            color:
                            _accent,

                            shape:
                            BoxShape
                                .circle,
                          ),
                        ),

                        SizedBox(
                          width:
                          9.w,
                        ),

                        Text(
                          'YOUR DATA • YOUR CONTROL',

                          style:
                          GoogleFonts.inter(
                            color:
                            secondary,

                            fontSize:
                            8.sp,

                            fontWeight:
                            FontWeight.w800,

                            letterSpacing:
                            1.8,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(
                      duration:
                      const Duration(
                        milliseconds:
                        550,
                      ),
                    )
                        .moveX(
                      begin:
                      -18,

                      end:
                      0,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),

                    SizedBox(
                      height:
                      13.h,
                    ),

                    // Main title
                    Text(
                      'PRIVACY',

                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        text,

                        fontSize:
                        86.sp,

                        height:
                        .76,

                        letterSpacing:
                        2.5,
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay:
                      const Duration(
                        milliseconds:
                        100,
                      ),

                      duration:
                      const Duration(
                        milliseconds:
                        850,
                      ),
                    )
                        .moveY(
                      begin:
                      65,

                      end:
                      0,

                      duration:
                      const Duration(
                        milliseconds:
                        900,
                      ),

                      curve:
                      Curves
                          .easeOutExpo,
                    )
                        .scale(
                      begin:
                      const Offset(
                        .92,
                        .92,
                      ),

                      end:
                      const Offset(
                        1,
                        1,
                      ),

                      duration:
                      const Duration(
                        milliseconds:
                        900,
                      ),

                      curve:
                      Curves
                          .easeOutExpo,
                    ),

                    SizedBox(
                      height:
                      16.h,
                    ),

                    // Description
                    SizedBox(
                      width:
                      340.w,

                      child:
                      Text(
                        'A clear look at how Frames handles your information, wallpapers and preferences.',

                        style:
                        GoogleFonts.inter(
                          color:
                          secondary,

                          fontSize:
                          14.sp,

                          height:
                          1.75,

                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                      delay:
                      const Duration(
                        milliseconds:
                        300,
                      ),

                      duration:
                      const Duration(
                        milliseconds:
                        700,
                      ),
                    )
                        .moveY(
                      begin:
                      22,

                      end:
                      0,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),

                    SizedBox(
                      height:
                      24.h,
                    ),

                    // Hero metadata
                    Row(
                      children: [
                        _HeroMeta(
                          value:
                          '01',

                          label:
                          'PRIVACY',

                          text:
                          text,

                          secondary:
                          secondary,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        _VerticalDivider(
                          color:
                          divider,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        _HeroMeta(
                          value:
                          'LOCAL',

                          label:
                          'PREFERENCES',

                          text:
                          text,

                          secondary:
                          secondary,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        _VerticalDivider(
                          color:
                          divider,
                        ),

                        SizedBox(
                          width:
                          20.w,
                        ),

                        _HeroMeta(
                          value:
                          'FRAMES',

                          label:
                          'PLATFORM',

                          text:
                          text,

                          secondary:
                          secondary,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(
                      delay:
                      const Duration(
                        milliseconds:
                        450,
                      ),
                    )
                        .moveY(
                      begin:
                      20,

                      end:
                      0,

                      curve:
                      Curves
                          .easeOutExpo,
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // QUICK PRINCIPLES
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  22.h,
                ),

                child:
                _PrinciplesCard(
                  text:
                  text,

                  secondary:
                  secondary,

                  accent:
                  _accent,

                  surface:
                  surface,

                  surfaceSoft:
                  surfaceSoft,

                  divider:
                  divider,
                )
                    .animate()
                    .fadeIn(
                  delay:
                  const Duration(
                    milliseconds:
                    350,
                  ),

                  duration:
                  const Duration(
                    milliseconds:
                    750,
                  ),
                )
                    .moveY(
                  begin:
                  35,

                  end:
                  0,

                  curve:
                  Curves
                      .easeOutExpo,
                ),
              ),
            ),

            // ======================================================
            // POLICY
            // ======================================================

            SliverPadding(
              padding:
              EdgeInsets.symmetric(
                horizontal:
                20.w,
              ),

              sliver:
              SliverToBoxAdapter(
                child:
                _PolicyCard(
                  text:
                  text,

                  secondary:
                  secondary,

                  accent:
                  _accent,

                  surface:
                  surface,

                  surfaceSoft:
                  surfaceSoft,

                  divider:
                  divider,
                ),
              ),
            ),

            // ======================================================
            // FOOTER
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20.w,
                  34.h,
                  20.w,
                  100.h,
                ),

                child:
                Column(
                  children: [
                    Container(
                      width:
                      38.w,

                      height:
                      2,

                      decoration:
                      BoxDecoration(
                        color:
                        _accent,

                        borderRadius:
                        BorderRadius
                            .circular(
                          10.r,
                        ),
                      ),
                    ),

                    SizedBox(
                      height:
                      14.h,
                    ),

                    Text(
                      'FRAMES',

                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        text,

                        fontSize:
                        27.sp,

                        letterSpacing:
                        2.4,
                      ),
                    ),

                    SizedBox(
                      height:
                      5.h,
                    ),

                    Text(
                      'PRIVACY • EXPERIENCE • SIMPLICITY',

                      textAlign:
                      TextAlign
                          .center,

                      style:
                      GoogleFonts.inter(
                        color:
                        muted.withOpacity(
                          .65,
                        ),

                        fontSize:
                        7.sp,

                        fontWeight:
                        FontWeight.w800,

                        letterSpacing:
                        1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// BACK BUTTON
// ==================================================================

class _BackButton
    extends StatefulWidget {
  final Color text;
  final Color accent;
  final Color surface;
  final Color divider;

  const _BackButton({
    required this.text,
    required this.accent,
    required this.surface,
    required this.divider,
  });

  @override
  State<_BackButton> createState() =>
      _BackButtonState();
}

class _BackButtonState
    extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(
      onTapDown:
          (_) {
        setState(() {
          _pressed =
          true;
        });
      },

      onTapCancel:
          () {
        setState(() {
          _pressed =
          false;
        });
      },

      onTapUp:
          (_) {
        setState(() {
          _pressed =
          false;
        });

        Navigator.pop(
          context,
        );
      },

      child:
      AnimatedScale(
        scale:
        _pressed ? .88 : 1,

        duration:
        const Duration(
          milliseconds:
          160,
        ),

        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds:
            220,
          ),

          width:
          50.w,

          height:
          50.w,

          decoration:
          BoxDecoration(
            color:
            _pressed
                ? widget.accent
                .withOpacity(
              .08,
            )
                : widget.surface
                .withOpacity(
              .65,
            ),

            shape:
            BoxShape.circle,

            border:
            Border.all(
              color:
              _pressed
                  ? widget.accent
                  .withOpacity(
                .24,
              )
                  : widget.divider,
            ),
          ),

          child:
          Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color:
            widget.text,

            size:
            17.sp,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// HEADER BADGE
// ==================================================================

class _HeaderBadge
    extends StatelessWidget {
  final Color accent;
  final Color text;
  final Color divider;

  const _HeaderBadge({
    required this.accent,
    required this.text,
    required this.divider,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.symmetric(
        horizontal:
        12.w,

        vertical:
        9.h,
      ),

      decoration:
      BoxDecoration(
        color:
        accent.withOpacity(
          .06,
        ),

        borderRadius:
        BorderRadius.circular(
          16.r,
        ),

        border:
        Border.all(
          color:
          divider,
        ),
      ),

      child:
      Row(
        mainAxisSize:
        MainAxisSize.min,

        children: [
          Container(
            width:
            6.w,

            height:
            6.w,

            decoration:
            BoxDecoration(
              color:
              accent,

              shape:
              BoxShape.circle,
            ),
          ),

          SizedBox(
            width:
            7.w,
          ),

          Text(
            'V3',

            style:
            GoogleFonts.inter(
              color:
              text,

              fontSize:
              9.sp,

              fontWeight:
              FontWeight.w800,

              letterSpacing:
              1,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// HERO META
// ==================================================================

class _HeroMeta
    extends StatelessWidget {
  final String value;
  final String label;
  final Color text;
  final Color secondary;

  const _HeroMeta({
    required this.value,
    required this.label,
    required this.text,
    required this.secondary,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Flexible(
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            value,

            maxLines:
            1,

            overflow:
            TextOverflow.ellipsis,

            style:
            GoogleFonts.bebasNeue(
              color:
              text,

              fontSize:
              19.sp,

              height:
              .8,

              letterSpacing:
              1,
            ),
          ),

          SizedBox(
            height:
            5.h,
          ),

          Text(
            label,

            maxLines:
            1,

            overflow:
            TextOverflow.ellipsis,

            style:
            GoogleFonts.inter(
              color:
              secondary.withOpacity(
                .55,
              ),

              fontSize:
              6.5.sp,

              fontWeight:
              FontWeight.w800,

              letterSpacing:
              1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// VERTICAL DIVIDER
// ==================================================================

class _VerticalDivider
    extends StatelessWidget {
  final Color color;

  const _VerticalDivider({
    required this.color,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      1,

      height:
      26.h,

      color:
      color,
    );
  }
}

// ==================================================================
// PRINCIPLES CARD
// ==================================================================

class _PrinciplesCard
    extends StatelessWidget {
  final Color text;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color surfaceSoft;
  final Color divider;

  const _PrinciplesCard({
    required this.text,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.surfaceSoft,
    required this.divider,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.all(
        20.w,
      ),

      decoration:
      BoxDecoration(
        color:
        surface,

        borderRadius:
        BorderRadius.circular(
          30.r,
        ),

        border:
        Border.all(
          color:
          divider,
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width:
                38.w,

                height:
                38.w,

                decoration:
                BoxDecoration(
                  color:
                  accent.withOpacity(
                    .08,
                  ),

                  shape:
                  BoxShape.circle,
                ),

                child:
                Icon(
                  Icons
                      .shield_outlined,

                  color:
                  accent,

                  size:
                  19.sp,
                ),
              ),

              SizedBox(
                width:
                13.w,
              ),

              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      'THE FRAMES APPROACH',

                      style:
                      GoogleFonts.inter(
                        color:
                        text,

                        fontSize:
                        11.sp,

                        fontWeight:
                        FontWeight.w800,

                        letterSpacing:
                        .6,
                      ),
                    ),

                    SizedBox(
                      height:
                      3.h,
                    ),

                    Text(
                      'Simple. Local. Transparent.',

                      style:
                      GoogleFonts.inter(
                        color:
                        secondary,

                        fontSize:
                        10.sp,

                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height:
            18.h,
          ),

          Container(
            height:
            1,

            color:
            divider,
          ),

          SizedBox(
            height:
            18.h,
          ),

          Row(
            children: [
              Expanded(
                child:
                _Principle(
                  icon:
                  Icons
                      .lock_outline_rounded,

                  title:
                  'PRIVATE',

                  subtitle:
                  'No unnecessary personal data.',

                  text:
                  text,

                  secondary:
                  secondary,

                  accent:
                  accent,
                ),
              ),

              SizedBox(
                width:
                10.w,
              ),

              Expanded(
                child:
                _Principle(
                  icon:
                  Icons
                      .phone_android_rounded,

                  title:
                  'LOCAL',

                  subtitle:
                  'Preferences stay on your device.',

                  text:
                  text,

                  secondary:
                  secondary,

                  accent:
                  accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PRINCIPLE
// ==================================================================

class _Principle
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color text;
  final Color secondary;
  final Color accent;

  const _Principle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.text,
    required this.secondary,
    required this.accent,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.all(
        13.w,
      ),

      decoration:
      BoxDecoration(
        color:
        accent.withOpacity(
          .035,
        ),

        borderRadius:
        BorderRadius.circular(
          20.r,
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          Icon(
            icon,

            color:
            accent,

            size:
            19.sp,
          ),

          SizedBox(
            height:
            10.h,
          ),

          Text(
            title,

            style:
            GoogleFonts.inter(
              color:
              text,

              fontSize:
              8.sp,

              fontWeight:
              FontWeight.w800,

              letterSpacing:
              1,
            ),
          ),

          SizedBox(
            height:
            4.h,
          ),

          Text(
            subtitle,

            maxLines:
            2,

            overflow:
            TextOverflow.ellipsis,

            style:
            GoogleFonts.inter(
              color:
              secondary,

              fontSize:
              8.sp,

              height:
              1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// POLICY CARD
// ==================================================================

class _PolicyCard
    extends StatelessWidget {
  final Color text;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color surfaceSoft;
  final Color divider;

  const _PolicyCard({
    required this.text,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.surfaceSoft,
    required this.divider,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      EdgeInsets.fromLTRB(
        22.w,
        24.h,
        22.w,
        22.h,
      ),

      decoration:
      BoxDecoration(
        color:
        surface,

        borderRadius:
        BorderRadius.circular(
          32.r,
        ),

        border:
        Border.all(
          color:
          divider,
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          _PolicySection(
            number:
            '01',

            title:
            'Information Collection',

            body:
            'Frames does not collect personal information such as passwords, payment details, or sensitive user data. The app may temporarily store cached wallpapers and preference settings locally on your device to improve performance and user experience.',

            text:
            text,

            secondary:
            secondary,

            accent:
            accent,

            divider:
            divider,
          ),

          _PolicyDivider(
            divider:
            divider,
          ),

          _PolicySection(
            number:
            '02',

            title:
            'Wallpaper Sources',

            body:
            'Wallpapers displayed inside the application are fetched through APIs and publicly available sources merged into one platform for a seamless browsing experience.',

            text:
            text,

            secondary:
            secondary,

            accent:
            accent,

            divider:
            divider,
          ),

          _PolicyDivider(
            divider:
            divider,
          ),

          _PolicySection(
            number:
            '03',

            title:
            'Device Storage',

            body:
            'Downloaded wallpapers and cached images are stored locally on your device. Users can clear cached data anytime from the preferences section.',

            text:
            text,

            secondary:
            secondary,

            accent:
            accent,

            divider:
            divider,
          ),

          _PolicyDivider(
            divider:
            divider,
          ),

          _PolicySection(
            number:
            '04',

            title:
            'Third-Party Services',

            body:
            'Some services used within Frames may rely on third-party APIs or image providers. We do not control external platforms or their independent privacy practices.',

            text:
            text,

            secondary:
            secondary,

            accent:
            accent,

            divider:
            divider,
          ),

          _PolicyDivider(
            divider:
            divider,
          ),

          _PolicySection(
            number:
            '05',

            title:
            'Policy Updates',

            body:
            'This privacy policy may be updated in future versions of the application to reflect improvements, features, or legal requirements.',

            text:
            text,

            secondary:
            secondary,

            accent:
            accent,

            divider:
            divider,
          ),

          SizedBox(
            height:
            22.h,
          ),

          // Version pill
          Container(
            padding:
            EdgeInsets.symmetric(
              horizontal:
              14.w,

              vertical:
              9.h,
            ),

            decoration:
            BoxDecoration(
              color:
              accent.withOpacity(
                .07,
              ),

              borderRadius:
              BorderRadius.circular(
                18.r,
              ),

              border:
              Border.all(
                color:
                divider,
              ),
            ),

            child:
            Row(
              mainAxisSize:
              MainAxisSize.min,

              children: [
                Container(
                  width:
                  6.w,

                  height:
                  6.w,

                  decoration:
                  BoxDecoration(
                    color:
                    accent,

                    shape:
                    BoxShape.circle,
                  ),
                ),

                SizedBox(
                  width:
                  8.w,
                ),

                Text(
                  'FRAMES • VERSION 3',

                  style:
                  GoogleFonts.inter(
                    color:
                    text,

                    fontSize:
                    8.sp,

                    fontWeight:
                    FontWeight.w800,

                    letterSpacing:
                    1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      delay:
      const Duration(
        milliseconds:
        250,
      ),

      duration:
      const Duration(
        milliseconds:
        800,
      ),
    )
        .moveY(
      begin:
      35,

      end:
      0,

      curve:
      Curves.easeOutExpo,
    );
  }
}

// ==================================================================
// POLICY SECTION
// ==================================================================

class _PolicySection
    extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final Color text;
  final Color secondary;
  final Color accent;
  final Color divider;

  const _PolicySection({
    required this.number,
    required this.title,
    required this.body,
    required this.text,
    required this.secondary,
    required this.accent,
    required this.divider,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,

      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment
              .center,

          children: [
            Container(
              width:
              34.w,

              height:
              34.w,

              alignment:
              Alignment.center,

              decoration:
              BoxDecoration(
                color:
                accent.withOpacity(
                  .06,
                ),

                borderRadius:
                BorderRadius.circular(
                  12.r,
                ),

                border:
                Border.all(
                  color:
                  divider,
                ),
              ),

              child:
              Text(
                number,

                style:
                GoogleFonts.inter(
                  color:
                  accent,

                  fontSize:
                  8.sp,

                  fontWeight:
                  FontWeight.w800,

                  letterSpacing:
                  1,
                ),
              ),
            ),

            SizedBox(
              width:
              12.w,
            ),

            Expanded(
              child:
              Text(
                title,

                style:
                GoogleFonts.inter(
                  color:
                  text,

                  fontSize:
                  16.sp,

                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height:
          13.h,
        ),

        Padding(
          padding:
          EdgeInsets.only(
            left:
            46.w,
          ),

          child:
          Text(
            body,

            style:
            GoogleFonts.inter(
              color:
              secondary,

              fontSize:
              12.5.sp,

              height:
              1.85,

              fontWeight:
              FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// POLICY DIVIDER
// ==================================================================

class _PolicyDivider
    extends StatelessWidget {
  final Color divider;

  const _PolicyDivider({
    required this.divider,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      EdgeInsets.symmetric(
        vertical:
        22.h,
      ),

      child:
      Container(
        height:
        1,

        color:
        divider,
      ),
    );
  }
}