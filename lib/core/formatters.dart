String formatPeso(double amount) {
  final hasCents = amount != amount.roundToDouble();
  final fixed = amount.toStringAsFixed(hasCents ? 2 : 0);
  final parts = fixed.split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  return parts.length > 1 ? '₱$whole.${parts[1]}' : '₱$whole';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${_months[local.month - 1]} ${local.day}, ${local.year} · '
      '$hour:$minute $period';
}

String formatOrderNumber(int id) => '#${id.toString().padLeft(5, '0')}';
