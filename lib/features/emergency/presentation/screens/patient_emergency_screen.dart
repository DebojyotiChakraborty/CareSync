import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/confirm_sheet.dart';
import '../../../../core/design/linear_fade_appbar.dart';
import '../../../../core/design/squircle_card.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routing/route_names.dart';
import '../../../../services/custom_biometric_service.dart';
import '../../../../services/emergency_audit_service.dart';

class PatientEmergencyScreen extends ConsumerStatefulWidget {
  const PatientEmergencyScreen({super.key});

  @override
  ConsumerState<PatientEmergencyScreen> createState() =>
      _PatientEmergencyScreenState();
}

class _PatientEmergencyScreenState extends ConsumerState<PatientEmergencyScreen>
    with SingleTickerProviderStateMixin {
  bool _isIdentifying = false;
  String _scanningStatus = 'Initializing...';
  late AnimationController _scannerController;
  BiometricCancelToken? _activeCancelToken;
  bool _cooldownActive = false;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _activeCancelToken?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _scanFace() async {
    if (_cooldownActive) {
      debugPrint('[BIOMETRIC] Scan cooldown active. Ignoring duplicate request.');
      return;
    }

    _activeCancelToken?.cancel();
    final cancelToken = BiometricCancelToken();
    _activeCancelToken = cancelToken;

    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;
      if (cancelToken.isCancelled) return;

      setState(() {
        _isIdentifying = true;
        _scanningStatus = 'Uploading face scan...';
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && _isIdentifying && !cancelToken.isCancelled) {
          setState(() {
            _scanningStatus = 'Analyzing biometric coordinates...';
          });
        }
      });

      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted && _isIdentifying && !cancelToken.isCancelled) {
          setState(() {
            _scanningStatus = 'Searching CareSync registry...';
          });
        }
      });

      final identifyResult =
          await CustomBiometricService.instance.identifyPatientDetailed(
        File(image.path),
        cancelToken: cancelToken,
      );

      if (cancelToken.isCancelled) return;
      if (!mounted) return;

      setState(() {
        _isIdentifying = false;
      });

      if (identifyResult.status == BiometricResultStatus.success &&
          identifyResult.qrCodeId != null) {
        setState(() {
          _cooldownActive = true;
        });
        _cooldownTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _cooldownActive = false;
            });
          }
        });

        final qrCodeId = identifyResult.qrCodeId!;
        final fullName = identifyResult.fullName ?? 'Unknown';
        final confidence = identifyResult.confidence ?? 100.0;
        final patientId = identifyResult.patientId;
        final pose = identifyResult.poseMatched ?? 'neutral';

        await EmergencyAuditService.instance.logFaceScan(
          patientId: patientId,
          status: 'Success',
          confidence: confidence.toDouble(),
        );

        HapticFeedback.mediumImpact();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Matched Patient: $fullName (${confidence.toStringAsFixed(1)}% confidence, pose: $pose)',
            ),
            backgroundColor: context.tokens.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.push('${RouteNames.patientEmergencyView}/$qrCodeId');
      } else {
        final friendlyMessage =
            CustomBiometricService.instance.mapStatusToErrorMessage(
          identifyResult.status,
          identifyResult.errorMessage,
          errorCode: identifyResult.errorCode,
        );

        await EmergencyAuditService.instance.logFaceScan(
          patientId: null,
          status: 'Failed',
          confidence: 0.0,
          reason: friendlyMessage,
        );

        HapticFeedback.heavyImpact();

        if (identifyResult.status == BiometricResultStatus.noMatch) {
          _showNoMatchSheet(message: friendlyMessage);
        } else {
          _showErrorSheet(friendlyMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isIdentifying = false;
        });
      }
      debugPrint('[Emergency] Face scan identification error: $e');

      await EmergencyAuditService.instance.logFaceScan(
        patientId: null,
        status: 'Failed',
        confidence: 0.0,
        reason: 'Scanning Error',
      );

      HapticFeedback.heavyImpact();

      _showErrorSheet(e.toString());
    }
  }

  Future<void> _showNoMatchSheet(
      {String message = 'No Matching Patient Found'}) async {
    final retry = await showConfirmSheet(
      context,
      icon: Iconsax.warning_2,
      title: 'No Match Found',
      message:
          '$message\n\nWe could not find a matching patient profile in the CareSync database. Please check lighting, ensure the face is centered, or try scanning their physical QR code.',
      confirmLabel: 'Try Again',
      cancelLabel: 'Close',
    );
    if (retry) _scanFace();
  }

  void _showErrorSheet(String message) {
    showAlertSheet(
      context,
      icon: Iconsax.close_circle,
      title: 'Scanning Error',
      message:
          'An error occurred while matching the patient face:\n\n${message.contains("Exception:") ? message.split("Exception:").last : message}',
      buttonLabel: 'Close',
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CSScaffold(
      title: 'Emergency Center',
      automaticBack: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Banner ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: SquircleCard(
                    radius: AppSpacing.squircleGrouped,
                    color: t.tint,
                    borderSide:
                        BorderSide(color: t.accent.withValues(alpha: 0.25)),
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: t.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.danger, color: t.accent, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'First Responder Mode',
                                style: TextStyle(
                                  color: t.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Access critical patient medical information instantly during health crises.',
                                style: TextStyle(
                                  color: t.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                      24, 24, 24, MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Lookup Tools',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildToolCard(
                        context,
                        title: 'Scan Patient Face',
                        description:
                            'Identify an unconscious patient using AI face matching.',
                        icon: Iconsax.frame_1,
                        onTap: () => _scanFace(),
                      ),
                      const SizedBox(height: 14),
                      _buildToolCard(
                        context,
                        title: 'Scan Patient QR Code',
                        description:
                            'Scan physical emergency card or bracelet QR.',
                        icon: Iconsax.scan,
                        onTap: () =>
                            context.push(RouteNames.patientEmergencyScan),
                      ),
                      const SizedBox(height: 14),
                      _buildToolCard(
                        context,
                        title: 'My Emergency Medical ID',
                        description:
                            'View or share your personal emergency pass.',
                        icon: Iconsax.personalcard,
                        onTap: () => context.push(RouteNames.patientQrCode),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Biometric search scanning overlay (dark by design) ─────────────
          if (_isIdentifying)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Container(
                        width: 270,
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _scannerController,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 84,
                                      height: 84,
                                      child: CustomPaint(
                                        painter: _FaceBracketPainter(
                                          color: t.accent,
                                          animationValue:
                                              _scannerController.value,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: CustomPaint(
                                        painter: _FaceIdScannerPainter(
                                          color: Colors.white,
                                          animationValue:
                                              _scannerController.value,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'FACE ID SCAN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white60),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _scanningStatus,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      color: Colors.white60,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final t = context.tokens;
    return SquircleCard(
      radius: AppSpacing.squircleGrouped,
      borderSide: BorderSide(color: t.divider),
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: t.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: t.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: t.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Iconsax.arrow_right_1, color: t.textSecondary, size: 18),
        ],
      ),
    );
  }
}

// Apple Face ID-inspired camera corner brackets custom painter
class _FaceBracketPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _FaceBracketPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 + (animationValue * 0.7))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final length = 14.0;
    final r = 6.0;

    final pathTL = Path()
      ..moveTo(0, length)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(length, 0);
    canvas.drawPath(pathTL, paint);

    final pathTR = Path()
      ..moveTo(size.width, length)
      ..lineTo(size.width, r)
      ..quadraticBezierTo(size.width, 0, size.width - r, 0)
      ..lineTo(size.width - length, 0);
    canvas.drawPath(pathTR, paint);

    final pathBL = Path()
      ..moveTo(0, size.height - length)
      ..lineTo(0, size.height - r)
      ..quadraticBezierTo(0, size.height, r, size.height)
      ..lineTo(length, size.height);
    canvas.drawPath(pathBL, paint);

    final pathBR = Path()
      ..moveTo(size.width, size.height - length)
      ..lineTo(size.width, size.height - r)
      ..quadraticBezierTo(
          size.width, size.height, size.width - r, size.height)
      ..lineTo(size.width - length, size.height);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceBracketPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}

class _FaceIdScannerPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _FaceIdScannerPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4 + (animationValue * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double w = size.width;
    final double h = size.height;

    final facePath = Path()
      ..moveTo(w * 0.35, h * 0.4)
      ..lineTo(w * 0.35, h * 0.42)
      ..moveTo(w * 0.65, h * 0.4)
      ..lineTo(w * 0.65, h * 0.42)
      ..moveTo(w * 0.5, h * 0.4)
      ..lineTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.58, h * 0.55)
      ..moveTo(w * 0.38, h * 0.68)
      ..quadraticBezierTo(w * 0.5, h * 0.76, w * 0.62, h * 0.68)
      ..moveTo(w * 0.25, h * 0.3)
      ..lineTo(w * 0.25, h * 0.58)
      ..quadraticBezierTo(w * 0.25, h * 0.85, w * 0.5, h * 0.85)
      ..quadraticBezierTo(w * 0.75, h * 0.85, w * 0.75, h * 0.58)
      ..lineTo(w * 0.75, h * 0.3);

    canvas.drawPath(facePath, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceIdScannerPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}
