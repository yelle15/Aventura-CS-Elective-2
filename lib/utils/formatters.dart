String formatPeso(double price) {
  final digits = price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  return '₱$digits';
}
