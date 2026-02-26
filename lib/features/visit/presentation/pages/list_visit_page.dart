import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_non_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/detail_visit_page.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/prospect_visit_form_page.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/route_map_page.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/checkout_prospect_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListVisitPage extends StatelessWidget {
  const ListVisitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisitProvider(),
      child: const _ListVisitContent(),
    );
  }
}

class _ListVisitContent extends StatefulWidget {
  const _ListVisitContent({Key? key}) : super(key: key);

  @override
  State<_ListVisitContent> createState() => _ListVisitContentState();
}

class _ListVisitContentState extends State<_ListVisitContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController!.addListener(_fetchData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _checkOpenVisits();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    _tabController?.removeListener(_fetchData);

    _tabController?.dispose();

    super.dispose();
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final visitProvider = Provider.of<VisitProvider>(context, listen: false);

    if (_tabController?.index == 0) {
      await visitProvider.fetchVisitsNonProspect(
        authProvider.user!.userDetails.first.fUserDefault!,

        authProvider.token!,
      );
    } else {
      await visitProvider.fetchVisits(
        authProvider.user!.userDetails.first.fUserDefault!,

        authProvider.token!,
      );
    }
  }

  Future<void> _checkOpenVisits() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final visitProvider = Provider.of<VisitProvider>(context, listen: false);

    await visitProvider.checkOpenVisitWithoutCustomer(
      authProvider.user!.userDetails.first.fUserDefault!,
      authProvider.token!,
    );
  }

  void _onSearchSubmitted(String value) {
    Provider.of<VisitProvider>(context, listen: false).setSearchKeyword(value);

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,

        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,

          elevation: 0,

          centerTitle: true,

          leading: const BackButton(color: Colors.black),

          title: const Text(
            'History Visit',

            style: TextStyle(
              color: Colors.black,

              fontWeight: FontWeight.w400,

              fontSize: 18,
            ),
          ),

          bottom: TabBar(
            controller: _tabController,

            tabs: const [
              Tab(text: 'Rencana Visit'),

              Tab(text: 'Kunjungan Prospek'),
            ],

            labelColor: Colors.black,

            unselectedLabelColor: Colors.grey,

            indicatorColor: Colors.indigo,
          ),
        ),

        floatingActionButton: Consumer<VisitProvider>(
          builder: (context, visitProvider, child) {
            return FloatingActionButton(
              elevation: 6,
              shape: const CircleBorder(),
              backgroundColor: visitProvider.hasOpenVisitWithoutCustomer
                  ? Colors.grey
                  : const Color(0xFF5F6BF7),
              onPressed: visitProvider.hasOpenVisitWithoutCustomer
                  ? null
                  : () {
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProspectVisitFormPage(),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _fetchData();
                        }
                      });
                    },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            );
          },
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: TextField(
                  controller: _searchController,

                  decoration: const InputDecoration(
                    hintText: "Cari customer...",

                    border: InputBorder.none,

                    icon: Icon(Icons.search),
                  ),

                  onSubmitted: _onSearchSubmitted,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) => const RouteMapPage(),
                      ),
                    );
                  },

                  icon: const Icon(Icons.map),

                  label: const Text("Lihat Rute Hari Ini"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController,

                  children: [_buildNonProspectList(), _buildProspectList()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNonProspectList() {
    return Consumer<VisitProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.visits.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.visits.isEmpty) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.visits.isEmpty) {
          return const Center(child: Text('Tidak ada data visit.'));
        }

        final hasActiveVisit = provider.visits.any(
          (v) =>
              v.tVisitRealization?.startAt != null &&
              v.tVisitRealization?.endAt == null,
        );

        return RefreshIndicator(
          onRefresh: _fetchData,

          child: ListView.builder(
            itemCount: provider.visits.length,

            itemBuilder: (context, index) {
              final visit = provider.visits[index];

              return _visitCard(context, visit, hasActiveVisit);
            },
          ),
        );
      },
    );
  }

  Widget _buildProspectList() {
    return Consumer<VisitProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.visitsPros.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.visitsPros.isEmpty) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.visitsPros.isEmpty) {
          return const Center(child: Text('Tidak ada data visit prospek.'));
        }

        return RefreshIndicator(
          onRefresh: _fetchData,

          child: ListView.builder(
            itemCount: provider.visitsPros.length,

            itemBuilder: (context, index) {
              final visit = provider.visitsPros[index];

              return _prospectVisitCard(context, visit);
            },
          ),
        );
      },
    );
  }

  Widget _visitCard(
    BuildContext context,

    VisitSalesNonProspectDetail visit,

    bool hasActiveVisit,
  ) {
    final statusInfo = _getVisitStatus(visit);

    final isStarted = visit.tVisitRealization?.startAt != null;

    final isCompleted = visit.tVisitRealization?.endAt != null;

    final bool isEnabled = isStarted || isCompleted || !hasActiveVisit;

    final VoidCallback? onTap = isEnabled
        ? () {
            if (visit.customerId == null && !isCompleted) {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => CheckoutProspectPage(visitId: visit.id),
                ),
              ).then((value) {
                if (value == true) {
                  _fetchData();
                }
              });

              return;
            }

            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) => DetailVisitPage(
                  visitPlanId: visit.id,

                  customerId: visit.customerId!,

                  realizationId: visit.tVisitRealization?.id,
                ),
              ),
            ).then((value) {
              if (value == true) {
                _fetchData();
              }
            });
          }
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Material(
        color: Colors.transparent,

        borderRadius: BorderRadius.circular(14),

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(14),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  visit.customerName ?? 'Nama Customer Tidak Tersedia',

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,

                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(.1),

                        borderRadius: BorderRadius.circular(6),
                      ),

                      child: Text(
                        statusInfo['text'],

                        style: TextStyle(color: statusInfo['color']),
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (visit.customerId == null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,

                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(.2),

                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Text(
                          'Prospek',

                          style: TextStyle(
                            color: Colors.amber.shade800,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    Text(visit.tVisitSale?.code ?? 'No Code'),

                    const Spacer(),

                    IconButton(
                      icon: Icon(statusInfo['icon']),

                      onPressed: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _prospectVisitCard(BuildContext context, VisitSalesDetail visit) {
    final statusInfo = _getProspectVisitStatus(visit);

    final VoidCallback? onTap = visit.endAt == null
        ? () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) => CheckoutProspectPage(visitId: visit.id),
              ),
            ).then((value) {
              if (value == true) {
                _fetchData();
              }
            });
          }
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),
      ),

      child: Material(
        color: Colors.transparent,

        borderRadius: BorderRadius.circular(14),

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(14),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  visit.customerName ?? 'Nama Customer Tidak Tersedia',

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,

                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(.1),

                        borderRadius: BorderRadius.circular(6),
                      ),

                      child: Text(
                        statusInfo['text'],

                        style: TextStyle(color: statusInfo['color']),
                      ),
                    ),

                    const Spacer(),

                    IconButton(
                      icon: Icon(statusInfo['icon']),

                      onPressed: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getVisitStatus(VisitSalesNonProspectDetail visit) {
    if (visit.tVisitRealization != null) {
      if (visit.tVisitRealization!.endAt != null) {
        return {
          'text': 'Selesai',

          'color': Colors.green,

          'icon': Icons.check_circle,
        };
      }

      if (visit.tVisitRealization!.startAt != null) {
        return {
          'text': 'Sudah Check-in',

          'color': Colors.orange,

          'icon': Icons.logout,
        };
      }
    }

    return {
      'text': 'Belum Check-in',

      'color': Colors.grey,

      'icon': Icons.login,
    };
  }

  Map<String, dynamic> _getProspectVisitStatus(VisitSalesDetail visit) {
    if (visit.endAt != null) {
      return {
        'text': 'Selesai',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    }

    if (visit.startAt != null) {
      return {
        'text': 'Sudah Check-in',
        'color': Colors.orange,
        'icon': Icons.logout,
      };
    }

    return {
      'text': 'Belum Check-in',
      'color': Colors.grey,
      'icon': Icons.login,
    };
  }
}
