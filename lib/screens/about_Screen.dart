import 'package:dotty/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Provider/version_provider.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({
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
                            'About',

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

                    _BuildBadge(
                      text:
                      text,

                      accent:
                      _accent,

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
                  44.h,
                  22.w,
                  30.h,
                ),

                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
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
                          'THE STORY BEHIND FRAMES',

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

                    Text(
                      'FRAMES',

                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        text,

                        fontSize:
                        88.sp,

                        height:
                        .76,

                        letterSpacing:
                        3,
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

                    SizedBox(
                      width:
                      345.w,

                      child:
                      Text(
                        'Immersive wallpapers crafted for modern devices, cinematic setups and people who care about what appears on their screen.',

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
                      25.h,
                    ),

                    Row(
                      children: [
                        _HeroMeta(
                          value:
                          '03',

                          label:
                          'RELEASE',

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
                          '4K',

                          label:
                          'VISUALS',

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
                          '∞',

                          label:
                          'MOODS',

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
            // BUILD CARD
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  18.h,
                ),

                child:
                _BuildCard(
                  text:
                  text,

                  secondary:
                  secondary,

                  accent:
                  _accent,

                  surface:
                  surface,

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
                  30,

                  end:
                  0,

                  curve:
                  Curves
                      .easeOutExpo,
                ),
              ),
            ),

            // ======================================================
            // ABOUT CARD
            // ======================================================

            SliverToBoxAdapter(
              child:
              Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  20.w,
                ),

                child:
                _AboutCard(
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
                    450,
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
                  Curves
                      .easeOutExpo,
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
                  40.h,
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
                          20.r,
                        ),
                      ),
                    ),

                    SizedBox(
                      height:
                      15.h,
                    ),

                    Text(
                      'FRAMES',

                      style:
                      GoogleFonts.bebasNeue(
                        color:
                        text,

                        fontSize:
                        28.sp,

                        letterSpacing:
                        2.5,
                      ),
                    ),

                    SizedBox(
                      height:
                      5.h,
                    ),

                    Text(
                      'BUILT FOR THE WAY YOUR SCREEN FEELS',

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
// BUILD BADGE
// ==================================================================

class _BuildBadge
    extends StatelessWidget {
  final Color text;
  final Color accent;
  final Color divider;

  const _BuildBadge({
    required this.text,
    required this.accent,
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
        CrossAxisAlignment
            .start,

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
              20.sp,

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
      27.h,

      color:
      color,
    );
  }
}

// ==================================================================
// BUILD CARD
// ==================================================================

class _BuildCard
    extends StatelessWidget {
  final Color text;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color divider;

  const _BuildCard({
    required this.text,
    required this.secondary,
    required this.accent,
    required this.surface,
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
        CrossAxisAlignment
            .start,

        children: [
          Row(
            children: [
              Container(
                width:
                42.w,

                height:
                42.w,

                decoration:
                BoxDecoration(
                  color:
                  accent.withOpacity(
                    .07,
                  ),

                  shape:
                  BoxShape.circle,
                ),

                child:
                Icon(
                  Icons
                      .auto_awesome_rounded,

                  color:
                  accent,

                  size:
                  20.sp,
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
                      'CURRENT BUILD',

                      style:
                      GoogleFonts.inter(
                        color:
                        secondary,

                        fontSize:
                        8.sp,

                        fontWeight:
                        FontWeight.w800,

                        letterSpacing:
                        1.5,
                      ),
                    ),

                    SizedBox(
                      height:
                      3.h,
                    ),

                    Text(
                      '${AppInfo.buildNumber} • ${AppInfo.buildCodename}',

                      style:
                      GoogleFonts.inter(
                        color:
                        text,

                        fontSize:
                        14.sp,

                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  10.w,

                  vertical:
                  7.h,
                ),

                decoration:
                BoxDecoration(
                  color:
                  accent.withOpacity(
                    .07,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    14.r,
                  ),

                  border:
                  Border.all(
                    color:
                    divider,
                  ),
                ),

                child:
                Text(
                  'STABLE',

                  style:
                  GoogleFonts.inter(
                    color:
                    text,

                    fontSize:
                    7.sp,

                    fontWeight:
                    FontWeight.w800,

                    letterSpacing:
                    1,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height:
            19.h,
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

          Text(
            'A renewed wallpaper experience focused on visual quality, smooth interaction and a cleaner design language.',

            style:
            GoogleFonts.inter(
              color:
              secondary,

              fontSize:
              12.5.sp,

              height:
              1.8,

              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ABOUT CARD
// ==================================================================

class _AboutCard
    extends StatelessWidget {
  final Color text;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color surfaceSoft;
  final Color divider;

  const _AboutCard({
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
                    .07,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    13.r,
                  ),
                ),

                child:
                Icon(
                  Icons
                      .info_outline_rounded,

                  color:
                  accent,

                  size:
                  19.sp,
                ),
              ),

              SizedBox(
                width:
                12.w,
              ),

              Text(
                'ABOUT FRAMES',

                style:
                GoogleFonts.inter(
                  color:
                  text,

                  fontSize:
                  16.sp,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),

          SizedBox(
            height:
            20.h,
          ),

          _Paragraph(
            text:
            'All wallpapers you are viewing inside Frames are delivered through multiple APIs and sources merged together into one premium experience. Our system brings high-quality wallpapers from various platforms together to create a smooth and immersive discovery experience.',

            secondary:
            secondary,
          ),

          SizedBox(
            height:
            20.h,
          ),

          _Paragraph(
            text:
            'Frames is the third renewed version of our wallpaper application, redesigned around a cleaner visual language, smoother animations, modern glass aesthetics and a more immersive browsing experience.',

            secondary:
            secondary,
          ),

          SizedBox(
            height:
            20.h,
          ),

          _Paragraph(
            text:
            'This version focuses on premium UI design, cinematic presentation, fast performance and curated wallpaper collections crafted for modern devices.',

            secondary:
            secondary,
          ),

          SizedBox(
            height:
            24.h,
          ),

          Container(
            padding:
            EdgeInsets.all(
              15.w,
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

              border:
              Border.all(
                color:
                divider,
              ),
            ),

            child:
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
                    accent,

                    shape:
                    BoxShape
                        .circle,
                  ),
                ),

                SizedBox(
                  width:
                  10.w,
                ),

                Expanded(
                  child:
                  Text(
                    'Designed to make every screen feel intentional.',

                    style:
                    GoogleFonts.inter(
                      color:
                      text,

                      fontSize:
                      10.sp,

                      fontWeight:
                      FontWeight.w700,

                      height:
                      1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PARAGRAPH
// ==================================================================

class _Paragraph
    extends StatelessWidget {
  final String text;
  final Color secondary;

  const _Paragraph({
    required this.text,
    required this.secondary,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      text,

      style:
      GoogleFonts.inter(
        color:
        secondary,

        fontSize:
        12.5.sp,

        height:
        1.9,

        fontWeight:
        FontWeight.w500,
      ),
    );
  }
}