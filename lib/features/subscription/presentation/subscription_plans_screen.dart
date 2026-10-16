import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/widgets/cards/subscription_plan_card.dart';
import '../../../shared/widgets/feedback/app_loading.dart';
import '../../../shared/widgets/layouts/responsive_scaffold.dart';
import '../view_model/subscription_bloc.dart';
import '../view_model/subscription_event.dart';
import '../view_model/subscription_state.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(LoadSubscriptionPlansRequested());
  }

  void _onProceedToCheckout(SubscriptionPlan plan) {
    Navigator.of(context).pushNamed(
      RouteNames.subscriptionCheckout,
      arguments: plan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Clinical Subscription Plans',
      currentRoute: RouteNames.subscriptionPlans,
      maxWidth: 1200,
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.isLoading && state.availablePlans.isEmpty) {
            return const AppLoading(message: 'Loading clinical subscription tiers...');
          }

          final plans = state.availablePlans;
          final isDesktop = ResponsiveUtils.isDesktop(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Flexible Monthly Plans for Dental Practices',
                textAlign: TextAlign.center,
                style: AppTypography.displayLarge.copyWith(fontSize: 26),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'All plans include core AI diagnostic assistance, HIPAA/GDPR clinical compliance, and cloud backup.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Plans Grid / Column
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: plans.map((plan) {
                    final isSelected = state.selectedPlan?.id == plan.id;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: SubscriptionPlanCard(
                          plan: plan,
                          isSelected: isSelected,
                          onSelect: () => context.read<SubscriptionBloc>().add(SelectSubscriptionPlan(plan)),
                          onCheckout: () => _onProceedToCheckout(plan),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length,
                  separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isSelected = state.selectedPlan?.id == plan.id;
                    return SubscriptionPlanCard(
                      plan: plan,
                      isSelected: isSelected,
                      onSelect: () => context.read<SubscriptionBloc>().add(SelectSubscriptionPlan(plan)),
                      onCheckout: () => _onProceedToCheckout(plan),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
