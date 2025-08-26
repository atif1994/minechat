class PlanFeature {
  final String label;
  final bool included;
  final String? linkText;
  final void Function()? onTap;

  const PlanFeature({
    required this.label,
    this.included = true,
    this.linkText,
    this.onTap,
  });
}
