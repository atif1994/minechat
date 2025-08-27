class PlanLabelLink {
  final String label; // can be empty for link-only ("Limits apply")
  final String linkText; // underlined clickable text
  final void Function()? onTap; // callback

  const PlanLabelLink({
    this.label = "",
    required this.linkText,
    this.onTap,
  });
}
