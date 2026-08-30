// Store Owner Dashboard: summary stats for one store's dashboard home (see
// backend/src/services/storeService.js#getDashboardStats /
// GET /api/stores/:storeId/dashboard). ordersByStatus always carries exactly
// the keys pending/confirmed/preparing/shipped/delivered (0 when a store has
// no orders in that status yet) -- the same order-status set the rest of
// this feature uses (Order.formattedStatus, the transition map on the
// backend). 'cancelled' is intentionally not included here: it isn't part of
// the fulfillment pipeline a store owner is progressing orders through.
class DashboardStats {
  final Map<String, int> ordersByStatus;
  final int productCount;

  DashboardStats({
    required this.ordersByStatus,
    required this.productCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final rawStatuses = json['ordersByStatus'] as Map<String, dynamic>? ?? {};
    return DashboardStats(
      ordersByStatus: rawStatuses.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );
  }

  int get pendingCount => ordersByStatus['pending'] ?? 0;
  int get confirmedCount => ordersByStatus['confirmed'] ?? 0;
  int get preparingCount => ordersByStatus['preparing'] ?? 0;
  int get shippedCount => ordersByStatus['shipped'] ?? 0;
  int get deliveredCount => ordersByStatus['delivered'] ?? 0;

  int get totalOrders => ordersByStatus.values.fold(0, (sum, count) => sum + count);
}
