import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/feedback/app_success_state.dart';
import '../data/payment_repository.dart';
import '../view_model/payment_bloc.dart';
import '../view_model/payment_event.dart';
import '../view_model/payment_state.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final SubscriptionPlan plan;

  const PaymentCheckoutScreen({
    super.key,
    required this.plan,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  PaymentOutcome _simulatedOutcome = PaymentOutcome.success;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(InitializeCheckoutSession(widget.plan));
  }

  void _onPayNow() {
    context.read<PaymentBloc>().add(ProcessPaymentTransaction(_simulatedOutcome));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout & Subscription Activation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: BlocConsumer<PaymentBloc, PaymentState>(
              listener: (context, state) {
                // Backend verification listener
              },
              builder: (context, state) {
                if (state.step == PaymentStep.success) {
                  return AppCard(
                    padding: AppSpacing.paddingXl,
                    child: AppSuccessState(
                      title: 'Payment & Subscription Confirmed!',
                      message:
                          'Your payment was verified by the backend. ${widget.plan.name} is now ACTIVE for your dental clinic.',
                      actionText: 'Go to Practice Dashboard',
                      onAction: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteNames.subscriptionStatus,
                          (route) => false,
                        );
                      },
                    ),
                  );
                }

                if (state.step == PaymentStep.processing) {
                  return const AppCard(
                    padding: AppSpacing.paddingXl,
                    child: AppLoading(
                      message: 'Processing Payment with Payment Gateway...\nPlease do not close or refresh this screen.',
                    ),
                  );
                }

                if (state.step == PaymentStep.verifyingBackend) {
                  return const AppCard(
                    padding: AppSpacing.paddingXl,
                    child: AppLoading(
                      message: 'Payment received!\nVerifying authoritative subscription state with backend...',
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage != null) ...[
                      StatusCard(
                        title: state.step == PaymentStep.cancelled ? 'Payment Cancelled' : 'Payment Failed',
                        message: state.errorMessage,
                        type: state.step == PaymentStep.cancelled ? StatusType.warning : StatusType.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Order Summary Card
                    AppCard(
                      padding: AppSpacing.paddingLg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Summary', style: AppTypography.titleLarge),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.plan.name, style: AppTypography.headlineMedium),
                              Text(widget.plan.formattedPrice, style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          _buildSummaryRow('Billing Period', 'Monthly (auto-renewing)'),
                          const SizedBox(height: AppSpacing.xs),
                          _buildSummaryRow('Clinic Seats Included', widget.plan.limits['Staff Seats']?.toString() ?? '15 Seats'),
                          const SizedBox(height: AppSpacing.xs),
                          _buildSummaryRow('Taxes & Compliance Fee', '${widget.plan.currency}0.00'),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Due Today', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                '${widget.plan.currency}${widget.plan.monthlyPrice.toStringAsFixed(0)}',
                                style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Test Gateway Simulation Controls
                    AppCard(
                      backgroundColor: AppColors.surfaceVariant.withAlpha(120),
                      padding: AppSpacing.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SIMULATE PAYMENT OUTCOME FOR TESTING:',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            children: [
                              ChoiceChip(
                                label: const Text('Success (Normal)'),
                                selected: _simulatedOutcome == PaymentOutcome.success,
                                onSelected: (sel) {
                                  if (sel) setState(() => _simulatedOutcome = PaymentOutcome.success);
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Card Decline / Failure'),
                                selected: _simulatedOutcome == PaymentOutcome.failure,
                                onSelected: (sel) {
                                  if (sel) setState(() => _simulatedOutcome = PaymentOutcome.failure);
                                },
                              ),
                              ChoiceChip(
                                label: const Text('User Cancelled'),
                                selected: _simulatedOutcome == PaymentOutcome.cancelled,
                                onSelected: (sel) {
                                  if (sel) setState(() => _simulatedOutcome = PaymentOutcome.cancelled);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    PrimaryButton(
                      text: state.step == PaymentStep.failed || state.step == PaymentStep.cancelled
                          ? 'Retry Payment'
                          : 'Pay ${widget.plan.currency}${widget.plan.monthlyPrice.toStringAsFixed(0)} & Activate',
                      isLoading: state.isProcessing,
                      icon: Icons.lock_outline_rounded,
                      onPressed: state.isProcessing ? null : _onPayNow,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: Text(
                        '🔒 256-Bit SSL Encrypted Healthcare Payment Gateway',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
