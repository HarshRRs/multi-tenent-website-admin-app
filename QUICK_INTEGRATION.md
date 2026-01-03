# 🚀 Quick Integration Guide

## Step-by-Step Backend Integration

### 1. Update main.dart (2 minutes)

Replace the current main.dart with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your existing router or app

void main() {
  runApp(
    const ProviderScope(  // Wrap with ProviderScope
      child: MyApp(),
    ),
  );
}

// Rest of your app code stays the same
```

### 2. Update Login Screen (5 minutes)

**File**: `lib/features/auth/presentation/login_screen.dart`

Add at the top:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/features/auth/presentation/auth_provider.dart';
```

Change from `StatefulWidget` to `ConsumerStatefulWidget`:
```dart
class LoginScreen extends ConsumerStatefulWidget {  // Changed
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();  // Changed
}

class _LoginScreenState extends ConsumerState<LoginScreen> {  // Changed
```

Replace `_handleLogin()` method:
```dart
Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    // Use provider instead of simulated delay
    await ref.read(authNotifierProvider.notifier).login(
      _emailController.text,
      _passwordController.text,
    );

    final authState = ref.read(authNotifierProvider);
    
    if (mounted && authState.status == AuthStatus.authenticated) {
      context.go('/');
    } else if (authState.error != null) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.error!)),
      );
    }
  }
}
```

Add loading indicator:
```dart
@override
Widget build(BuildContext context) {
  final authState = ref.watch(authNotifierProvider);
  final isLoading = authState.status == AuthStatus.loading;

  // Use isLoading for button state
}
```

### 3. Update Orders Screen (10 minutes)

**File**: `lib/features/orders/presentation/orders_screen.dart`

Add imports:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/features/orders/presentation/orders_provider.dart';
```

Change to `ConsumerStatefulWidget`:
```dart
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
```

Remove mock data and use provider:
```dart
@override
Widget build(BuildContext context) {
  final ordersState = ref.watch(ordersProvider);
  
  // Remove: final List<Order> _allOrders = [...];
  // Use: ordersState.orders instead
  
  return Scaffold(
    appBar: AppBar(
      title: const Text('Live Orders'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(ordersProvider.notifier).refresh(),
        ),
      ],
    ),
    body: ordersState.status == DataStatus.loading && ordersState.orders.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildKanbanBoard(ordersState.orders),
  );
}
```

Update status change handler:
```dart
void _onOrderDropped(Order order, OrderStatus newStatus) async {
  if (order.status == newStatus) return;

  try {
    await ref.read(ordersProvider.notifier).updateOrderStatus(
      order.id,
      newStatus,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${order.id} moved to ${_getStatusName(newStatus)}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

Update KanbanColumn to use filtered data:
```dart
KanbanColumn(
  title: 'New',
  status: OrderStatus.newOrder,
  orders: ordersState.ordersByStatus(OrderStatus.newOrder),  // Changed
  onOrderDropped: _onOrderDropped,
  headerColor: AppColors.info,
  icon: Icons.notifications_active,
),
```

### 4. Update Dashboard Screen (10 minutes)

**File**: `lib/features/dashboard/presentation/dashboard_screen.dart`

Add imports:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/features/dashboard/presentation/dashboard_provider.dart';
```

Change to `ConsumerWidget`:
```dart
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
```

Replace mock data with real data:
```dart
// Remove mock stats, use:
HeroStatCard(
  title: 'Total Revenue',
  value: '\$${dashboardState.stats?.totalRevenue.toStringAsFixed(2) ?? '0.00'}',
  trend: dashboardState.stats?.revenueTrend ?? '+0%',
  isPositive: dashboardState.stats?.isRevenueTrendPositive ?? true,
),

QuickStatCard(
  title: 'Active Orders',
  value: '${dashboardState.stats?.activeOrders ?? 0}',
  icon: Icons.receipt_long,
  baseColor: AppColors.info,
),

QuickStatCard(
  title: 'Reservations',
  value: '${dashboardState.stats?.reservations ?? 0}',
  icon: Icons.calendar_today,
  baseColor: Colors.purple,
),

QuickStatCard(
  title: 'Menu Active',
  value: '${dashboardState.stats?.menuItemsActive ?? 0}',
  icon: Icons.restaurant_menu,
  baseColor: Colors.orange,
),

QuickStatCard(
  title: 'Rating',
  value: '${dashboardState.stats?.rating.toStringAsFixed(1) ?? '0.0'}',
  icon: Icons.star,
  baseColor: AppColors.warning,
),
```

Add pull-to-refresh:
```dart
body: RefreshIndicator(
  onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
  child: CustomScrollView(
    // existing slivers...
  ),
),
```

Add loading state:
```dart
if (dashboardState.status == DataStatus.loading && dashboardState.stats == null)
  const Center(child: CircularProgressIndicator())
else
  // existing dashboard content
```

### 5. Configure API URLs (1 minute)

**File**: `lib/core/network/api_client.dart`
```dart
static const String baseUrl = 'https://your-api-server.com/api';  // UPDATE THIS
```

**File**: `lib/core/network/websocket_service.dart`
```dart
static const String wsUrl = 'wss://your-api-server.com/ws';  // UPDATE THIS
```

### 6. Test the Integration (5 minutes)

1. Run the app:
   ```bash
   flutter run
   ```

2. Test login flow:
   - Enter credentials
   - Should see loading indicator
   - Should navigate to dashboard on success

3. Test dashboard:
   - Should load cached data instantly
   - Should refresh in background
   - Pull to refresh should work

4. Test orders:
   - Should display orders from API
   - Drag & drop should trigger optimistic update
   - Should show error if API fails

### 7. Handle Backend Not Ready (Mock Mode)

If your backend API isn't ready yet, create a mock flag:

**Create**: `lib/core/config/app_config.dart`
```dart
class AppConfig {
  static const bool useMockData = true;  // Set to false when backend ready
  static const String apiBaseUrl = useMockData 
      ? 'http://localhost:3000'  // Local mock server
      : 'https://your-api-server.com/api';  // Production API
}
```

Then update api_client.dart to use:
```dart
static String get baseUrl => AppConfig.apiBaseUrl;
```

### 8. Add Error Handling UI (Optional but Recommended)

Create a reusable error widget:

**Create**: `lib/core/components/error_widget.dart`
```dart
import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

Use in screens:
```dart
if (state.status == DataStatus.error)
  ErrorDisplay(
    message: state.error ?? 'An error occurred',
    onRetry: () => ref.read(provider.notifier).refresh(),
  )
```

## ⚡ Quick Checklist

- [ ] Wrap app with ProviderScope in main.dart
- [ ] Update login screen to use authNotifierProvider
- [ ] Update orders screen to use ordersProvider
- [ ] Update dashboard screen to use dashboardProvider
- [ ] Configure API base URL
- [ ] Configure WebSocket URL (optional for now)
- [ ] Test login flow
- [ ] Test orders loading and updates
- [ ] Test dashboard data loading
- [ ] Add error handling UI
- [ ] Test with poor network conditions
- [ ] Test offline mode (should show cached data)

## 🎯 Expected Results

After integration:
- ✅ Login authenticates via API
- ✅ Dashboard loads from cache instantly, refreshes in background
- ✅ Orders load from API with loading indicator
- ✅ Order status changes trigger optimistic UI update
- ✅ Pull-to-refresh works on all screens
- ✅ Errors show user-friendly messages
- ✅ Offline mode shows cached data

## 🆘 Common Issues

**Issue**: Provider not found error
**Solution**: Make sure ProviderScope wraps your app in main.dart

**Issue**: Can't build after changes
**Solution**: Run `flutter clean && flutter pub get`

**Issue**: API calls timing out
**Solution**: Check API base URL, verify backend is running, check network

**Issue**: State not updating
**Solution**: Make sure using ConsumerWidget/ConsumerStatefulWidget, use ref.watch()

**Issue**: WebSocket not connecting
**Solution**: WebSocket is optional for now, comment out if backend doesn't support it

## 📞 Need Help?

Check the comprehensive documentation:
- `BACKEND_README.md` - Full technical documentation
- `BACKEND_IMPLEMENTATION.md` - Implementation summary
- Backend optimization design in `.qoder/quests/backend-optimization.md`

---

**Estimated Total Integration Time: 30-45 minutes**

Once completed, your app will have industry-level backend performance! 🚀
