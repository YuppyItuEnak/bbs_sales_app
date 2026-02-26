import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/customer/customer_address_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:bbs_sales_app/data/models/expedition/expedition_model.dart';
import 'package:bbs_sales_app/data/models/item/selected_item_model.dart';
import 'package:bbs_sales_app/data/models/item/item_model.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/expedition_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/top_provider.dart';
import 'package:bbs_sales_app/features/quotation/presentation/providers/quotation_provider.dart';
import 'package:bbs_sales_app/data/models/quotation/sales_quotation_post_model.dart';
import 'package:bbs_sales_app/features/quotation/presentation/widget/quotation_item_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customer_list_page.dart';
import 'product_group_page.dart';
import 'package:bbs_sales_app/features/quotation/presentation/pages/quotation_form_page.dart'
    show PriceBelowWarning;
import 'package:bbs_sales_app/features/quotation/presentation/providers/ppn_provider.dart';

class QuotationEditPage extends StatefulWidget {
  final String quotationId;

  const QuotationEditPage({super.key, required this.quotationId});

  @override
  State<QuotationEditPage> createState() => _QuotationEditPageState();
}

class _QuotationEditPageState extends State<QuotationEditPage> {
  CustomerSimpleModel? _selectedCustomer;
  CustomerAddressModel? _selectedAddress;
  MGenModel? _selectedTop;
  ExpeditionModel? _selectedExpedition;
  MGenModel? _selectedPpn;
  final List<SelectedItem> _selectedItems = [];
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _internalNoteController = TextEditingController();

  String? _quotationCode;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quotationProvider = Provider.of<QuotationProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      final token = authProvider.token!;

      // Load all data in parallel
      await Future.wait([
        quotationProvider.fetchQuotationDetail(widget.quotationId, token),
        Provider.of<TopProvider>(context, listen: false).fetchTopOptions(token),
        Provider.of<ExpeditionProvider>(
          context,
          listen: false,
        ).fetchExpeditions(token),
        Provider.of<PpnProvider>(context, listen: false).fetchPpnOptions(token),
      ]);

      // Initialize form with existing data
      final quotation = quotationProvider.selectedQuotation;
      if (quotation != null) {
        _noteController.text = quotation.notes ?? '';
        _internalNoteController.text = quotation.internalNote ?? '';
        if (!mounted) return;
        setState(() {
          _quotationCode = quotation.code;
          _selectedCustomer = CustomerSimpleModel(
            id: quotation.customerId ?? '',
            name: quotation.customerName ?? '',
          );
          _selectedAddress = CustomerAddressModel(
            id: quotation.addressId ?? '',
            name: quotation.shipToAddress ?? '',
            address: quotation.shipToAddress ?? '',
            deliveryAreaId: quotation.deliveryAreaId ?? '',
            deliveryAreaName: quotation.deliveryAreaName ?? '',
            customerId: quotation.customerId ?? '',
            isDefault: false,
            notes: '',
            isActive: true,
          );
          _selectedTop = MGenModel(
            id: quotation.topId ?? '',
            group: '',
            value1: quotation.top ?? '',
          );
          _selectedExpedition = ExpeditionModel(
            id: quotation.expeditionId ?? '',
            code: '',
            name: quotation.expeditionName ?? '',
            address: '',
            isActive: true,
          );
          _selectedPpn = MGenModel(
            id: quotation.ppnType ?? '',
            group: '',
            key1:
                (quotation.ppnTypeText?.toLowerCase().contains('include') ??
                    false)
                ? 'include'
                : quotation.ppnType,
            value1: quotation.ppnTypeText ?? '',
            value2: quotation.ppnValue?.toString() ?? '',
          );

          for (var detail in quotation.items) {
            _selectedItems.add(
              SelectedItem(
                item: ItemModel(
                  id: detail.itemId,
                  code: detail.itemCode ?? '',
                  name: detail.itemName ?? '',
                  uom: detail.uom,
                  uomId: detail.uomId,
                ),
                price: detail.price,
                quantity: detail.qty.toInt(),
                discountPercent: detail.disc1,
                discountValue: detail.discAmount,
              ),
            );
          }

          _isInitialized = true;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _internalNoteController.dispose();
    super.dispose();
  }

  void _navigateToCustomerList() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerListPage()),
    );

    if (result != null) {
      setState(() {
        _selectedCustomer = result['customer'] as CustomerSimpleModel?;
        _selectedAddress = result['address'] as CustomerAddressModel?;
      });
    }
  }

  void _showTopOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<TopProvider>(
          builder: (context, topProvider, child) {
            if (topProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (topProvider.error != null) {
              return Center(child: Text(topProvider.error!));
            }
            return ListView.builder(
              itemCount: topProvider.topOptions.length,
              itemBuilder: (context, index) {
                final top = topProvider.topOptions[index];
                return ListTile(
                  title: Text(top.value1 ?? ''),
                  onTap: () {
                    setState(() {
                      _selectedTop = top;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showExpeditionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<ExpeditionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text(provider.error!));
            }
            if (provider.expeditions.isEmpty) {
              return const Center(child: Text('Tidak ada data ekspedisi'));
            }
            return ListView.builder(
              itemCount: provider.expeditions.length,
              itemBuilder: (context, index) {
                final expedition = provider.expeditions[index];
                return ListTile(
                  title: Text(expedition.name),
                  onTap: () {
                    setState(() {
                      _selectedExpedition = expedition;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _navigateAndAddItems() async {
    if (_selectedCustomer == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ups! 😆',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Barang sudah siap dimasukkan,\n'
                'tapi customernya belum dipilih.\n\n'
                'Yuk pilih dulu, kasihan barangnya nanti bingung mau ke mana 🥲',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F6BF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Pilih Customer',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final newItems = await Navigator.push<List<SelectedItem>>(
      context,
      MaterialPageRoute(builder: (_) => const ProductGroupPage()),
    );
    if (newItems != null) {
      setState(() {
        for (var newItem in newItems) {
          final index = _selectedItems.indexWhere(
            (item) => item.item.id == newItem.item.id,
          );
          if (index != -1) {
            _selectedItems[index].quantity += newItem.quantity;
          } else {
            _selectedItems.add(newItem);
          }
        }
      });
    }
  }

  double _getComparisonPrice(SelectedItem selectedItem) {
    final segment = _selectedCustomer?.segment?.toLowerCase();
    final pricelist = selectedItem.item.pricelist;
    if (pricelist == null) return 0.0;
    switch (segment) {
      case 'grosir':
        return pricelist.priceGrosir;
      case 'retail':
        return pricelist.priceRetail;
      case 'agen':
        return pricelist.priceAgen;
      default:
        return 0.0;
    }
  }

  PriceBelowWarning _checkPriceBelow(
    double effectivePrice,
    double comparisonPrice,
  ) {
    if (comparisonPrice == 0.0 || effectivePrice == 0.0) {
      return PriceBelowWarning.none;
    }
    if (effectivePrice < (comparisonPrice * 0.9)) {
      return PriceBelowWarning.belowTenPercent;
    }
    if (effectivePrice < comparisonPrice) {
      return PriceBelowWarning.below;
    }
    return PriceBelowWarning.none;
  }

  void _showPpnOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<PpnProvider>(
          builder: (context, ppnProvider, child) {
            if (ppnProvider.isLoading && ppnProvider.ppnOptions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (ppnProvider.error != null) {
              return Center(child: Text(ppnProvider.error!));
            }
            if (ppnProvider.ppnOptions.isEmpty) {
              return const Center(child: Text('Tidak ada data PPN'));
            }
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Mode PPN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: ppnProvider.ppnOptions.length,
                    itemBuilder: (context, index) {
                      final ppnOption = ppnProvider.ppnOptions[index];
                      return ListTile(
                        title: Text(ppnOption.value1 ?? ''),
                        trailing: _selectedPpn?.id == ppnOption.id
                            ? const Icon(Icons.check, color: Color(0xFF5F6BF7))
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedPpn = ppnOption;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isFormValid() {
    final isValid =
        _selectedCustomer != null &&
        _selectedAddress != null &&
        _selectedTop != null &&
        _selectedExpedition != null &&
        _selectedPpn != null &&
        _selectedItems.isNotEmpty;
    return isValid;
  }

  void _submitForm({required bool isApproval}) async {
    if (!_isFormValid()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final quotationProvider = Provider.of<QuotationProvider>(
      context,
      listen: false,
    );

    if (authProvider.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build the quotation data
    final prefs = await SharedPreferences.getInstance();
    final unitBusinessId = prefs.getString('unit_bussiness_id');
    final salesId = authProvider.user?.userDetails.first.fUserDefault;
    final authUserId = authProvider.user?.id ?? '';

    final bool isPpnIncluded = _selectedPpn?.key1 == 'include';
    final double ppnRate =
        (_selectedPpn != null && _selectedPpn!.value2!.isNotEmpty)
        ? (double.tryParse(_selectedPpn!.value2!) ?? 11.0) / 100.0
        : 0.11;
    final double ppnMultiplier = 1.0 + ppnRate;

    // Calculate totals
    double totalDpp = 0;
    double totalDiscount = 0;

    for (var item in _selectedItems) {
      final finalPricePerUnit = item.price ?? item.item.pricelist?.price ?? 0;
      final dppPerUnit = finalPricePerUnit / ppnMultiplier;

      final dppSubtotal = dppPerUnit * item.quantity;
      final discountFromPercent = dppSubtotal * (item.discountPercent / 100);
      final itemTotalDiscount = discountFromPercent + item.discountValue;
      final dppItemAfterDiscounts = dppSubtotal - itemTotalDiscount;

      totalDpp += dppItemAfterDiscounts;
      totalDiscount += itemTotalDiscount;
    }

    final totalPpn = totalDpp * ppnRate;
    final grandTotal = (totalDpp + totalPpn);

    // Build details
    List<SalesQuotationDetailPostModel> details = _selectedItems.map((
      selectedItem,
    ) {
      final finalPricePerUnit =
          selectedItem.price ?? selectedItem.item.pricelist?.price ?? 0.0;

      double subtotal;
      double itemTotalDiscount;
      double totalTax;

      if (isPpnIncluded) {
        final grossTotal = finalPricePerUnit * selectedItem.quantity;
        final discountFromPercent =
            grossTotal * (selectedItem.discountPercent / 100);
        itemTotalDiscount = discountFromPercent + selectedItem.discountValue;
        subtotal = grossTotal - itemTotalDiscount;
        totalTax = subtotal - (subtotal / ppnMultiplier);
      } else {
        final dppPerUnit = finalPricePerUnit / ppnMultiplier;
        final dppSubtotal = dppPerUnit * selectedItem.quantity;
        final discountFromPercent =
            dppSubtotal * (selectedItem.discountPercent / 100);
        itemTotalDiscount = discountFromPercent + selectedItem.discountValue;
        subtotal = dppSubtotal - itemTotalDiscount;
        totalTax = subtotal * ppnRate;
      }

      return SalesQuotationDetailPostModel(
        itemId: selectedItem.item.id,
        qty: selectedItem.quantity,
        uomId: selectedItem.item.uomId,
        price: finalPricePerUnit,
        subtotal: subtotal,
        itemName: selectedItem.item.name,
        uomUnit: selectedItem.item.uom!,
        uomValue: 1,
        qtySnapshot: selectedItem.quantity,
        disc1: selectedItem.discountPercent,
        discAmount: selectedItem.discountValue,
        totalDisc: itemTotalDiscount,
        totalTax: totalTax,
        totalAmount: subtotal,
      );
    }).toList();

    // Determine status based on isApproval
    final int status = isApproval ? 1 : 1;

    // Add approval fields if isApproval is true
    final String? requestApprovalBy = isApproval ? authUserId : null;
    final String? requestApprovalAt = isApproval
        ? DateTime.now().toUtc().toIso8601String()
        : null;

    final quotationData = SalesQuotationPostModel(
      unitBussinessId: unitBusinessId ?? '',
      customerId: _selectedCustomer!.id,
      status: status,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      topId: _selectedTop!.id,
      salesId: salesId,
      currentApprovalLevel: 1,
      code: _quotationCode,
      total: grandTotal,
      approvalCount: 0,
      updatedBy: salesId,
      approvedCount: 0,
      source: "apps",
      createdBy: authProvider.user?.id ?? '',
      notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      addressId: _selectedAddress!.id,
      customerName: _selectedCustomer!.name,
      unitBussiness: unitBusinessId,
      sales: authProvider.user?.name,
      shipToName: _selectedCustomer!.name,
      shipToAddress: _selectedAddress!.address,
      deliveryAreaId: _selectedAddress!.deliveryAreaId,
      deliveryAreaName: _selectedAddress!.deliveryAreaName,
      top: _selectedTop!.value1,
      expeditionId: _selectedExpedition!.id,
      expeditionName: _selectedExpedition!.name,
      ppnType: _selectedPpn!.id,
      ppnTypeText: _selectedPpn!.value1,
      ppnValue: ppnRate * 100,
      dpp: totalDpp,
      dppLainnya: totalDpp * 11 / 12,
      totalDiscount: totalDiscount,
      grandTotal: grandTotal,
      ppn: totalPpn,
      isUsed: false,
      internalNote: _internalNoteController.text.isNotEmpty
          ? _internalNoteController.text
          : null,
      tSalesQuotationDs: details,
      requestApprovalBy: requestApprovalBy,
      requestApprovalAt: requestApprovalAt,
    );

    // First, update the quotation
    final updateSuccess = await quotationProvider.updateQuotation(
      widget.quotationId,
      quotationData,
      authProvider.token!,
    );

    if (!updateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quotationProvider.submitError ?? 'Failed to update quotation',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If isApproval is true, call the requestApproval API
    if (isApproval) {
      final approvalSuccess = await quotationProvider.requestApproval(
        authUserId: authUserId,
        salesQuotationId: widget.quotationId,
        token: authProvider.token!,
      );

      if (approvalSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quotation updated and approval requested!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              quotationProvider.submitError ?? 'Failed to request approval',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quotation updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isPpnIncluded = _selectedPpn?.key1 == 'include';
    final double ppnRate =
        (_selectedPpn != null && _selectedPpn!.value2!.isNotEmpty)
        ? (double.tryParse(_selectedPpn!.value2!) ?? 11.0) / 100.0
        : 0.11;
    final double ppnMultiplier = 1.0 + ppnRate;

    // --- Totals Calculation ---
    double totalDpp = 0;
    double totalDiscount = 0;

    for (var item in _selectedItems) {
      final finalPricePerUnit = item.price ?? item.item.pricelist?.price ?? 0;
      final dppPerUnit = finalPricePerUnit / ppnMultiplier;

      final dppSubtotal = dppPerUnit * item.quantity;
      final discountFromPercent = dppSubtotal * (item.discountPercent / 100);
      final itemTotalDiscount = discountFromPercent + item.discountValue;
      final dppItemAfterDiscounts = dppSubtotal - itemTotalDiscount;

      totalDpp += dppItemAfterDiscounts;
      totalDiscount += itemTotalDiscount;
    }

    final totalPpn = totalDpp * ppnRate;
    final grandTotal = (totalDpp + totalPpn);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Edit Quotation',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              InkWell(
                onTap: _navigateToCustomerList,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCustomer?.name ?? 'Pilih Customer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedCustomer != null
                                    ? const Color(0xFF5F6BF7)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToCustomerList,
                            child: const Text(
                              'Ubah',
                              style: TextStyle(
                                color: Color(0xFF5F6BF7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedAddress != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _selectedAddress!.address,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showTopOptions,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ToP',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        Text(_selectedTop?.value1 ?? 'Pilih ToP'),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showExpeditionOptions,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ekspedisi',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        Text(
                          _selectedExpedition?.name ?? 'Pilih Ekspedisi',
                          style: TextStyle(
                            color: _selectedExpedition == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Internal Note',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _internalNoteController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan internal...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                'Detail Item(${_selectedItems.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (_selectedItems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('Belum ada item yang ditambahkan.'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final selectedItem = _selectedItems[index];

                    // --- Start Item-specific Calculation ---
                    final finalPricePerUnit =
                        selectedItem.price ??
                        selectedItem.item.pricelist?.price ??
                        0.0;
                    final dppPerUnit = finalPricePerUnit / ppnMultiplier;

                    final dppSubtotal = dppPerUnit * selectedItem.quantity;
                    final discountFromPercent =
                        dppSubtotal * (selectedItem.discountPercent / 100);
                    final itemTotalDiscount =
                        discountFromPercent + selectedItem.discountValue;
                    final dppItemAfterDiscounts =
                        dppSubtotal - itemTotalDiscount;

                    double displaySubtotal;
                    if (isPpnIncluded) {
                      displaySubtotal = dppItemAfterDiscounts * ppnMultiplier;
                    } else {
                      displaySubtotal = dppItemAfterDiscounts;
                    }

                    final divisor =
                        selectedItem.item.weightMarketing ??
                        selectedItem.item.meter ??
                        1.0;
                    final effectivePrice = divisor == 0
                        ? 0
                        : dppItemAfterDiscounts /
                              (selectedItem.quantity * divisor);

                    final comparisonPriceNet =
                        _getComparisonPrice(selectedItem) / ppnMultiplier;
                    final warning = _checkPriceBelow(
                      effectivePrice.toDouble(),
                      comparisonPriceNet,
                    );
                    // --- End Item-specific Calculation ---

                    return QuotationItemCard(
                      key: ValueKey(selectedItem.item.id),
                      item: selectedItem,
                      customerSegment: _selectedCustomer?.segment,
                      displaySubtotal: displaySubtotal,
                      isPpnIncluded: isPpnIncluded,
                      warning: warning,
                      onQuantityChanged: (newQuantity) {
                        setState(() {
                          if (newQuantity > 0) {
                            selectedItem.quantity = newQuantity;
                          }
                        });
                      },
                      onDiscountChanged: (percent, value) {
                        setState(() {
                          selectedItem.discountPercent = percent;
                          selectedItem.discountValue = value;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _selectedItems.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _navigateAndAddItems,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF5F6BF7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '+ Tambah Barang',
                  style: TextStyle(color: Color(0xFF5F6BF7)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'DPP',
                      value:
                          'Rp ${NumberFormat.decimalPattern('id_ID').format(totalDpp)}',
                    ),
                    _SummaryRow(
                      label: 'Total Diskon',
                      value:
                          'Rp ${NumberFormat.decimalPattern('id_ID').format(totalDiscount)}',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('PPN (${_selectedPpn?.value2 ?? '...'}%)'),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _showPpnOptions,
                              child: const Text(
                                'Ubah',
                                style: TextStyle(
                                  color: Color(0xFF5F6BF7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Rp ${NumberFormat.decimalPattern('id_ID').format(totalPpn)}',
                            ),
                            const SizedBox(width: 8),
                            if (_selectedPpn != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPpnIncluded
                                      ? Colors.green[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedPpn?.value1?.toUpperCase() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isPpnIncluded
                                        ? Colors.green[800]
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: 'Total',
                      value:
                          'Rp ${NumberFormat.decimalPattern('id_ID').format(grandTotal)}',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<QuotationProvider>(
            builder: (context, quotationProvider, child) {
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF5F6BF7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          (_isFormValid() && !quotationProvider.isSubmitting)
                          ? () => _submitForm(isApproval: false)
                          : null,
                      child: quotationProvider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF5F6BF7),
                                ),
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(color: Color(0xFF5F6BF7)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F6BF7),
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          (_isFormValid() && !quotationProvider.isSubmitting)
                          ? () => _submitForm(isApproval: true)
                          : null,
                      child: quotationProvider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Update & Ajukan'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: bold ? const Color(0xFF5F6BF7) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
