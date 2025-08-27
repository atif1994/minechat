import 'package:minechat/model/data/subscriptions/billing_cycle.dart';
import 'package:minechat/model/data/subscriptions/subscription_plan.dart';

class SubscriptionService {
  const SubscriptionService();

  /// TODO: Wire to Firebase + Stripe via firestore-stripe-payments.
  Future<void> startCheckout({
    required SubscriptionPlan plan,
    required BillingCycle cycle,
    int quantity = 1,
  }) async {
    // Placeholder: open Stripe Checkout URL after Firebase doc writes back
    // Implement in the backend step.
  }

  /// TODO: Open customer billing portal (Stripe).
  Future<void> openBillingPortal() async {
    // Placeholder for portal session.
  }
}
