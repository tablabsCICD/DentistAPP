import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/widgets/cards/status_card.dart';
import '../../../shared/widgets/cards/subscription_status_card.dart';
import '../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../view_model/subscription_bloc.dart';
import '../view_model/subscription_event.dart';
import '../view_model/subscription_state.dart';

class CurrentSubscriptionScreen extends StatefulWidget {
  const CurrentSubscriptionScreen({super.key});

  @override
  State<CurrentSubscriptionScreen> createState() => _CurrentSubscriptionScreenState();
}

class _CurrentSubscriptionScreenState extends State<CurrentSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(LoadCurrentSubscriptionRequested());
  }

  void _onUpgrade() {
    Navigator.of(context).pushNamed(RouteNames.subscriptionPlans);
  }

  void _onDowngrade() {
    Navigator.of(context).pushNamed(RouteNames.subscriptionPlans);
  }

  void _onCancelSubscription(CurrentSubscription sub) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancel Subscription?',
      message:
          'Are you sure you want to cancel the ${sub.plan.name} subscription? You will retain access until ${sub.renewalDate.day}/${sub.renewalDate.month}/${sub.renewalDate.year}, after which AI scanning will be disabled.',
      confirmText: 'Yes, Cancel Plan',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<SubscriptionBloc>().add(CancelSubscriptionRequested(sub.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Subscription & Billing',
      currentRoute: RouteNames.subscriptionStatus,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<SubscriptionBloc>().add(LoadCurrentSubscriptionRequested()),
        ),
      ],
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.currentSubscription == null) {
            return const AppLoading(message: 'Loading subscription details...');
          }

          final subscription = state.currentSubscription ??
              CurrentSubscription(
                id: 'sub-demo-01',
                plan: const SubscriptionPlan(
                  id: 'plan-pro',
                  name: 'Professional Clinic',
                  monthlyPrice: 3999,
                  currency: '₹',
                  billingPeriod: 'month',
                  features: [
                    'Up to 5 Dentists',
                    '15 Staff Logins',
                    'Unlimited AI Scans & Diagnostics',
                    'Advanced Periodontal Charting',
                    'Priority 24/7 Support',
                  ],
                  limits: {'Dentists': '5', 'Staff Seats': '15'},
                ),
                status: SubscriptionStatus.active,
                startDate: DateTime.now().subtract(const Duration(days: 15)),
                renewalDate: DateTime.now().add(const Duration(days: 15)),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                StatusCard(
                  title: 'Subscription Notice',
                  message: state.errorMessage,
                  type: StatusType.warning,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SubscriptionStatusCard(
                subscription: subscription,
                onUpgrade: _onUpgrade,
                onDowngrade: _onDowngrade,
                onCancel: () => _onCancelSubscription(subscription),
                onRetryPayment: () => Navigator.of(context).pushNamed(
                  RouteNames.subscriptionCheckout,
                  arguments: subscription.plan,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
