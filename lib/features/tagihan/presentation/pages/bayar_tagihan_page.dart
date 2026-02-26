import 'dart:io';
import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/tagihan/invoice_detail_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/tagihan/presentation/providers/bayar_tagihan_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BayarTagihanPage extends StatelessWidget {
  final List<InvoiceItem> selectedInvoices;
  final double totalAmount;
  final String billingScheduleCustId;
  final List<InvoiceItem> allInvoices;

  const BayarTagihanPage({
    super.key,
    required this.selectedInvoices,
    required this.totalAmount,
    required this.billingScheduleCustId,
    required this.allInvoices,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BayarTagihanProvider(
        Provider.of<AuthProvider>(context, listen: false),
      ),
      child: BayarTagihanView(
        selectedInvoices: selectedInvoices,
        totalAmount: totalAmount,
        billingScheduleCustId: billingScheduleCustId,
        allInvoices: allInvoices,
      ),
    );
  }
}

class BayarTagihanView extends StatefulWidget {
  final List<InvoiceItem> selectedInvoices;
  final double totalAmount;
  final String billingScheduleCustId;
  final List<InvoiceItem> allInvoices;

  const BayarTagihanView({
    super.key,
    required this.selectedInvoices,
    required this.totalAmount,
    required this.billingScheduleCustId,
    required this.allInvoices,
  });

  @override
  State<BayarTagihanView> createState() => _BayarTagihanViewState();
}

class _BayarTagihanViewState extends State<BayarTagihanView> {
  final Map<String, TextEditingController> _invoiceControllers = {};
  late double _totalAmount;
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _editingFormatter = NumberFormat.decimalPattern('id_ID');
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _totalAmount = widget.totalAmount;

    for (var invoice in widget.selectedInvoices) {
      final controller = TextEditingController(
        text: _editingFormatter.format(invoice.tSalesInvoice.grandTotal),
      );
      controller.addListener(_updateTotalAmount);
      _invoiceControllers[invoice.tSalesInvoice.id] = controller;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BayarTagihanProvider>().init();
    });
  }

  void _updateTotalAmount() {
    double newTotal = 0;
    _invoiceControllers.forEach((_, controller) {
      newTotal += double.tryParse(controller.text.replaceAll('.', '')) ?? 0;
    });
    if (mounted && newTotal != _totalAmount) {
      setState(() => _totalAmount = newTotal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BayarTagihanProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Detail Tagihan',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5B67F1)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. 001",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Total Tagihan",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormatter.format(_totalAmount),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: const Color(0xFF5B67F1),
                      ),
                    ),
                    const Divider(height: 40, thickness: 1),

                    // Detail Tagihan Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle("Detail Tagihan"),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.selectedInvoices.map(
                      (invoice) => _invoicePaymentItem(invoice),
                    ),

                    const SizedBox(height: 20),
                    _sectionTitle("Nominal yang dibayarkan"),
                    _inputBoxStatic(_currencyFormatter.format(_totalAmount)),

                    _sectionTitle("Metode Pembayaran*"),
                    _buildDropdown(
                      hint: "Pilih",
                      value: provider.selectedPaymentMethod,
                      items: provider.paymentMethods,
                      onChanged: (val) => provider.setPaymentMethod(val),
                    ),

                    // Warning Box
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFE58F)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Perhatian!",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Tagihan customer ini tidak sepenuhnya tertagih!",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _sectionTitle("Alasan*"),
                    _buildDropdown(
                      hint: "Pilih",
                      value: provider.selectedReason,
                      items: provider.reasons,
                      onChanged: (val) => provider.setReason(val),
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle("Keterangan"),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      onChanged: (value) =>
                          context.read<BayarTagihanProvider>().setNote(value),
                      decoration: InputDecoration(
                        hintText: "Keterangan",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _sectionTitle("Bukti Penagihan*"),
                    _cameraBox(provider),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'EEEE, dd-MM-yyyy',
                            'id_ID',
                          ).format(provider.currentTime),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            "HH : mm : ss",
                          ).format(provider.currentTime),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Lokasi",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.currentAddress ?? "Mencari lokasi...",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 16),
                    if (provider.currentPosition != null)
                      Row(
                        children: [
                          _locationCoord(
                            "Latitude",
                            provider.currentPosition!.latitude.toStringAsFixed(
                              6,
                            ),
                          ),
                          const Spacer(),
                          _locationCoord(
                            "Longitude",
                            provider.currentPosition!.longitude.toStringAsFixed(
                              6,
                            ),
                            isRight: true,
                          ),
                        ],
                      ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validation for mandatory fields
                          if (provider.selectedPaymentMethod == null || provider.selectedPaymentMethod!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Metode Pembayaran tidak boleh kosong.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (provider.selectedReason == null || provider.selectedReason!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Alasan tidak boleh kosong.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (provider.pickedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bukti Penagihan tidak boleh kosong.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            await provider.submitPayment(
                              billingScheduleCustId:
                                  widget.billingScheduleCustId,
                              selectedInvoices: widget.selectedInvoices,
                              allInvoices: widget
                                  .selectedInvoices, // For now, assuming all selected are all
                              totalPayment: _totalAmount,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pembayaran berhasil disubmit'),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B67F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Submit",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _invoicePaymentItem(InvoiceItem invoice) {
    final controller = _invoiceControllers[invoice.tSalesInvoice.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.tSalesInvoice.code,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _currencyFormatter.format(invoice.tSalesInvoice.grandTotal),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            onChanged: (value) {
              String text = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (text.isEmpty) text = '0';
              final number = double.tryParse(text) ?? 0;
              final formattedText = _editingFormatter.format(number);
              if (formattedText != controller!.text) {
                controller.value = controller.value.copyWith(
                  text: formattedText,
                  selection: TextSelection.collapsed(
                    offset: formattedText.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<MGenModel> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      hint: Text(
        hint,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text(
                item.value1 ?? item.key1 ?? '',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _inputBoxStatic(String val) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      val,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );

  Widget _inputFieldLarge(String hint) => TextField(
    maxLines: 4,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    ),
  );

  Widget _cameraBox(BayarTagihanProvider provider) => GestureDetector(
    onTap: () => provider.pickImage(),
    child: Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5B67F1), width: 2),
        image: provider.pickedImage != null
            ? DecorationImage(
                image: FileImage(provider.pickedImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: provider.pickedImage == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 50, color: Colors.black54),
                const SizedBox(height: 10),
                Text(
                  "Ketuk untuk ambil gambar",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          : null,
    ),
  );

  Widget _locationCoord(String title, String val, {bool isRight = false}) =>
      Column(
        crossAxisAlignment: isRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            val,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ],
      );

  @override
  void dispose() {
    for (var controller in _invoiceControllers.values) {
      controller.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }
}
