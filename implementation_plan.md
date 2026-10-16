# AI Dental SaaS Flutter Project – Phase 1 Master Implementation Plan

Build a fresh, production-grade Flutter application from scratch for the **AI Dental SaaS Application** in `d:\Tablab Workspace\Dental App`.

The application implements a clean **feature-based Flutter architecture**, centralized design system, responsive layouts, API-ready repository patterns, mock data stores, role-based access control (RBAC), robust form validators, and authoritative state flows.

---

## User Review Required

> [!IMPORTANT]
> - **Scope Isolation**: This Phase 1 implementation covers strictly the modules outlined in the prompt (Foundation, Auth, Password Recovery, Onboarding, Verification, Onboarding Status, Subscription, Payment, Current Subscription, Clinic Settings, User Management). Unspecified future clinical modules (e.g. imaging, charting) are not implemented now, but the clean architecture allows seamless plug-in later.
> - **Payment Verification Rule**: Client-side payment checkout is not trusted as the final subscription state; after checkout completion/cancellation, the backend repository `refreshSubscriptionStatus()` is invoked to determine the authoritative subscription state.
> - **State Management**: Built using clean Flutter standard reactive patterns (ChangeNotifier / ValueNotifier / Provider-ready architecture) with zero boilerplate bloat, ensuring full testability, clean separation of concerns, and mockable data layers.

---

## Proposed Architecture & Directory Structure

```text
lib/
├── app/
│   ├── app.dart                          # Root MaterialApp with theme & routing
│   ├── config/
│   │   └── app_config.dart               # Environment constants & API config
│   ├── router/
│   │   ├── app_router.dart               # Centralized Navigator & Route Generator
│   │   ├── route_names.dart              # Centralized route string constants
│   │   └── route_guards.dart             # Post-login destination resolver & guards
│   └── theme/
│       ├── app_colors.dart               # Dental SaaS palette (primary teal, slate, surface, error)
│       ├── app_typography.dart           # Clean typography scales
│       ├── app_spacing.dart              # Standardized 4pt/8pt spacing & radii
│       └── app_theme.dart                # ThemeData definitions (Light & Dark)
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart            # App titles, regexes, limits, timeouts
│   ├── errors/
│   │   ├── app_exception.dart            # Base and specific business exceptions
│   │   └── failure.dart                  # User-friendly failure mapping
│   ├── extensions/
│   │   ├── context_extensions.dart       # Responsive breakpoints, theme shortcuts
│   │   └── string_extensions.dart        # Formatting helpers
│   ├── state/
│   │   └── view_state.dart               # Generic ViewState<T> (Idle, Loading, Success, Error)
│   ├── utils/
│   │   └── responsive_utils.dart         # Breakpoint helpers (Mobile, Tablet, Desktop)
│   └── validators/
│       └── app_validators.dart           # Centralized validators (Email, Password, Phone, OTP, etc.)
│
├── shared/
│   ├── models/
│   │   ├── user_model.dart               # User entity with UserRole & Permissions
│   │   ├── clinic_model.dart             # Clinic details, ClinicStatus & OperationalSettings
│   │   └── subscription_model.dart       # SubscriptionPlan, SubscriptionStatus, CurrentSubscription
│   └── widgets/
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   ├── outline_button.dart
│       │   ├── text_button.dart
│       │   └── loading_button.dart
│       ├── cards/
│       │   ├── app_card.dart
│       │   ├── status_card.dart
│       │   ├── progress_card.dart
│       │   ├── subscription_plan_card.dart
│       │   ├── subscription_status_card.dart
│       │   └── user_status_card.dart
│       ├── dialogs/
│       │   ├── confirmation_dialog.dart
│       │   ├── error_dialog.dart
│       │   └── success_dialog.dart
│       ├── feedback/
│       │   ├── app_loading.dart
│       │   ├── app_error_state.dart
│       │   ├── app_success_state.dart
│       │   └── app_empty_state.dart
│       ├── inputs/
│       │   ├── app_text_field.dart
│       │   ├── app_email_field.dart
│       │   ├── app_password_field.dart
│       │   ├── app_otp_field.dart
│       │   ├── app_phone_field.dart
│       │   └── app_dropdown.dart
│       └── layouts/
│           ├── responsive_scaffold.dart  # Responsive container & layout wrapper
│           └── auth_layout.dart          # Shared auth/onboarding split card layout
│
└── features/
    ├── authentication/
    │   ├── data/auth_repository.dart
    │   ├── domain/auth_state.dart
    │   └── presentation/login_screen.dart
    ├── password_recovery/
    │   ├── data/password_recovery_repository.dart
    │   ├── domain/password_recovery_state.dart
    │   └── presentation/
    │       ├── forgot_password_screen.dart
    │       ├── reset_code_screen.dart
    │       ├── new_password_screen.dart
    │       └── password_reset_success_screen.dart
    ├── clinic_onboarding/
    │   ├── data/clinic_onboarding_repository.dart
    │   ├── domain/onboarding_form_data.dart
    │   └── presentation/clinic_onboarding_screen.dart
    ├── verification/
    │   ├── data/verification_repository.dart
    │   ├── domain/verification_state.dart
    │   └── presentation/
    │       ├── email_verification_screen.dart
    │       └── otp_verification_screen.dart
    ├── onboarding_status/
    │   ├── data/onboarding_status_repository.dart
    │   ├── domain/onboarding_status_state.dart
    │   └── presentation/onboarding_status_screen.dart
    ├── subscription/
    │   ├── data/subscription_repository.dart
    │   ├── domain/subscription_controller.dart
    │   └── presentation/
    │       ├── subscription_plans_screen.dart
    │       └── current_subscription_screen.dart
    ├── payment/
    │   ├── data/payment_repository.dart
    │   ├── domain/payment_controller.dart
    │   └── presentation/payment_checkout_screen.dart
    ├── clinic_settings/
    │   ├── data/clinic_settings_repository.dart
    │   ├── domain/clinic_settings_controller.dart
    │   └── presentation/clinic_settings_screen.dart
    └── user_management/
        ├── data/user_management_repository.dart
        ├── domain/user_management_controller.dart
        └── presentation/
            ├── user_list_screen.dart
            └── invite_user_screen.dart
```

---

## Key Feature Implementation Details

### 1. Flutter Foundation & Design System
- Modern dental clinical design language: Deep Dental Cyan / Teal primary (`#00778A` / `#0E9F9F`), Dark Navy headers (`#0F172A`), Slate borders, soft background tints, WCAG AAA compliant contrast.
- Modularized typography (`AppTypography`) using standard Flutter text styles mapped cleanly to `ThemeData`.
- Standardized spacing (`AppSpacing.xs`, `sm`, `md`, `lg`, `xl`, `xxl`) and consistent corner radiuses (`AppRadii.card`, `AppRadii.button`, `AppRadii.input`).

### 2. Authentication & Post-Login Decision Tree
- Unified role-aware login UI for **Clinic Staff** and **Dentists** with role selector tab or auto-detection.
- Form validation, visibility toggle, error/retry states.
- **Post-Login Routing Engine**: Inspects `User -> ClinicStatus -> VerificationStatus -> SubscriptionStatus -> RemainingSteps` to navigate intelligently:
  - Not Onboarded $\rightarrow$ `/clinic-onboarding`
  - Unverified Email $\rightarrow$ `/email-verification` or `/otp-verification`
  - Unsubscribed $\rightarrow$ `/subscription/plans`
  - Payment Pending / Blocked $\rightarrow$ `/onboarding-status`
  - Fully Active $\rightarrow$ `/subscription/status` or `/clinic-settings` / `/users`

### 3. Password Recovery Flow
- 4 connected screens: `ForgotPassword` $\rightarrow$ `ResetCode` (with resend cooldown timer & expired token simulation) $\rightarrow$ `NewPassword` (with password strength check) $\rightarrow$ `PasswordResetSuccess` $\rightarrow$ Back to Login.

### 4. SaaS Clinic Onboarding & Verification
- Multi-step form with step preservation:
  - Step 1: Clinic Details (Name, Type, Address, City, State, Country, Postal, Website)
  - Step 2: Administrator Details (Name, Email, Phone, Role)
  - Step 3: Contact & Emergency Info
- Verification screen supporting dual modes (Email-link simulation & 6-digit OTP entry with cooldown timer).

### 5. Onboarding Status Dashboard
- Interactive status timeline showing step progress:
  - Clinic Details (Complete)
  - Verification (Complete / Pending)
  - Subscription (Pending / Active)
  - Activation (Active / Blocked / Incomplete)
- Clear guidance on blockers (e.g. payment required, verification needed).

### 6. Subscription & Authoritative Payment Flow
- **Subscription Plans Screen**: Monthly tier cards (e.g. Solo Practitioner, Multi-Dentist Clinic, Enterprise), feature checklists, limits (users, patients, AI scans), clear selection state, checkout CTA.
- **Payment Checkout Screen**: Simulates checkout flow with 3 outcomes:
  - Payment Success $\rightarrow$ calls `SubscriptionRepository.refreshSubscriptionStatus()` $\rightarrow$ confirms ACTIVE status before proceeding.
  - Payment Failed $\rightarrow$ shows failure reason with immediate retry.
  - Payment Cancelled $\rightarrow$ graceful cancellation with retry.
- **Current Subscription Screen**: Displays active plan, renewal date, upgrade/downgrade/cancel options, grace period alerts, failed billing banners.

### 7. Clinic Settings & User Management
- **Role-Aware Clinic Settings**: Clinic Profile, Timezone dropdown, Operational hours & AI scanning rules. Permissions checked against `currentUser.role` (`Administrator` can edit all, `Dentist`/`Staff` have restricted or read-only views).
- **User Management**: Responsive table (desktop/tablet) and card list (mobile) with role badges, status toggle (active/deactivate), change role dialog, and **Invite User Form** with email/role validation and permission validation.

---

## Verification Plan

### Automated Verification
1. **`flutter analyze`**: Zero errors and zero warnings across the entire codebase.
2. **`flutter test`**: Full test suite covering:
   - Validators (email, password, phone, OTP, required strings)
   - Route Guards & Post-Login decision engine
   - Authentication controller (login success/failure, role states)
   - Password recovery repository and state transitions
   - Onboarding form state preservation & validation
   - Verification OTP validation and resend cooldown logic
   - Subscription plan model, selection, and current subscription status handling
   - Payment controller & authoritative backend status refresh rule
   - Clinic settings permission checks
   - User management permissions, activation/deactivation, invitation validation
3. **`flutter build` / Run sanity check**: Ensure application builds cleanly.

### Manual / Flow Verification
- Inspect the interactive screens, mock data flow, responsive layout switches, and step navigation.
