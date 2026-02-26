import 'package:bbs_sales_app/features/customer/presentation/providers/customer_list_provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
import 'package:bbs_sales_app/features/home/presentation/pages/home_page.dart';
import 'package:bbs_sales_app/features/item/presentation/providers/item_list_provider.dart';
import 'package:bbs_sales_app/features/performance/presentation/providers/performance_provider.dart';
import 'package:bbs_sales_app/features/prospect/presentation/providers/prospect_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/expedition_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/ppn_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/product_group_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/product_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/quotation_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/top_provider.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/providers/tagihan_provider.dart';
import 'package:bbs_sales_app/features/target/presentation/providers/target_sales_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_detail_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'core/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CustomerListProvider>(
          create: (context) => CustomerListProvider(
            token: null,
            salesId: null,
            unitBusinessId: null,
          ),
          update: (context, auth, previous) => CustomerListProvider(
            token: auth.token,
            salesId: auth.salesId,
            unitBusinessId: auth.unitBusinessId,
          ),
        ),
        ChangeNotifierProvider(create: (_) => QuotationProvider()),
        ChangeNotifierProvider(create: (_) => TopProvider()),
        ChangeNotifierProvider(create: (_) => ProductGroupProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ExpeditionProvider()),
        ChangeNotifierProvider(create: (_) => PpnProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => VisitDetailProvider()),
        ChangeNotifierProvider(create: (_) => ProspectProvider()),
        ChangeNotifierProvider(create: (_) => TargetSalesProvider()),
        ChangeNotifierProvider(create: (_) => PerformanceProvider()),
        ChangeNotifierProvider(
          create: (_) => TagihanProvider(context.read<AuthProvider>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CustomerFormProvider>(
          create: (context) =>
              CustomerFormProvider(token: '', unitBusinessId: ''),
          update: (context, auth, previous) => CustomerFormProvider(
            token: auth.token ?? '',
            unitBusinessId: auth.unitBusinessId ?? '',
          ),
        ),
        ChangeNotifierProvider(create: (_) => ItemListProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TagihanProvider>(
          create: (context) => TagihanProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => TagihanProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'BBS SALES App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const _RootPage(),
      ),
    );
  }
}

class _RootPage extends StatefulWidget {
  const _RootPage();

  @override
  State<_RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<_RootPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return authProvider.isAuthenticated
            ? const HomePage()
            : const LoginPage();
      },
    );
  }
}
