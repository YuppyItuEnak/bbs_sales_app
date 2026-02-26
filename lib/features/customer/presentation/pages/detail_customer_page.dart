import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDetailPage extends StatefulWidget {
  final bool isViewOnly;
  const CustomerDetailPage({super.key, this.isViewOnly = false});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  bool _isSubmitting = false;
  bool _expandNpwp = false;
  bool _expandAddress = false;
  bool _expandBank = false;
  bool _expandFav = false;
  bool _expandRestrict = false;
  bool _expandContact = false;
  String _salesName = "-";

  @override
  void initState() {
    super.initState();
    _loadSalesName();
  }

  Future<void> _loadSalesName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _salesName = prefs.getString('username') ?? "-");
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CustomerFormProvider>();
    final draft = form.draft;
    final status = form.editingCustomer?.status ?? 0;

    int restrictionCount = [
      draft.allowQuotation,
      draft.allowOrder,
      draft.allowDelivery,
      draft.allowInvoice,
      draft.allowReturn,
    ].where((e) => e).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.isViewOnly ? "Detail Customer" : "Edit Customer",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "${form.prefix?.value1 ?? ''} ${form.name ?? '-'}"
                        .trim()
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D5FEF),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: _statusChip(status)),
                const SizedBox(height: 20),

                // --- Bagian Detail Customer ---
                _buildSectionHeader(
                  "Customer Group",
                  form.parentCustomer?.name ?? "-",
                ),
                _buildInfoCard([
                  _buildRowInfo("Taxable", form.taxable ?? "-"),
                  _buildRowInfo("ToP", form.top?.value1 ?? "-"),
                  _buildRowInfo("Contact Person", form.cpName ?? "-"),
                  _buildRowInfo("No. Telp. CP", form.cpPhone ?? "-"),
                ]),

                // --- Bagian NPWP ---
                _buildSectionHeader(
                  "NPWP",
                  _expandNpwp ? "Tutup" : "Lihat Semua",
                  isAction: true,
                  onTap: () => setState(() => _expandNpwp = !_expandNpwp),
                ),
                if (_expandNpwp)
                  ...draft.npwps.map(
                    (e) => _buildDataCard(
                      title: e.name,
                      subtitle: e.number,
                      trailing: e.isDefault
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : null,
                      content: e.address,
                    ),
                  ),

                // --- Bagian Alamat ---
                _buildSectionHeader(
                  "Alamat",
                  _expandAddress ? "Tutup" : "Lihat Semua",
                  isAction: true,
                  onTap: () => setState(() => _expandAddress = !_expandAddress),
                ),
                if (_expandAddress)
                  ...draft.addresses.map(
                    (e) => _buildDataCard(
                      title: e.label,
                      subtitle: e.isDefault ? "Default" : "",
                      content: e.fullAddress,
                    ),
                  ),

                // --- Bagian Rekening ---
                _buildSectionHeader(
                  "Rekening",
                  _expandBank ? "Tutup" : "Lihat Semua",
                  isAction: true,
                  onTap: () => setState(() => _expandBank = !_expandBank),
                ),
                if (_expandBank)
                  ...draft.banks.map(
                    (e) => _buildDataCard(
                      title: "${e.bank} | ${e.accountNumber}",
                      subtitle: e.accountName,
                      trailing: e.isDefault
                          ? const Text(
                              "Default",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                  ),

                // --- Bagian Item Favorite ---
                _buildSectionHeader(
                  "Item Favorite (${draft.favoriteItems.length})",
                  _expandFav ? "Tutup" : "Lihat Semua",
                  isAction: true,
                  onTap: () => setState(() => _expandFav = !_expandFav),
                ),
                if (_expandFav)
                  ...draft.favoriteItems.map(
                    (e) => _buildDataCard(title: e.name, subtitle: ""),
                  ),

                // --- Bagian Restriction ---
                _buildSectionHeader(
                  "Restriction ($restrictionCount)",
                  _expandRestrict ? "Tutup" : "Lihat Semua",
                  isAction: true,
                  onTap: () =>
                      setState(() => _expandRestrict = !_expandRestrict),
                ),
                if (_expandRestrict) ...[
                  _buildRestrictionCard(
                    "Sales Quotation",
                    draft.allowQuotation,
                  ),
                  _buildRestrictionCard("Sales Order", draft.allowOrder),
                  _buildRestrictionCard("Delivery Order", draft.allowDelivery),
                  _buildRestrictionCard("Sales Invoice", draft.allowInvoice),
                  _buildRestrictionCard("Sales Retur", draft.allowReturn),
                ],

                // --- Bagian Kontak ---
                _buildSectionHeader(
                  "Kontak (${draft.contacts.length})",
                  _expandContact ? "Tutup" : "Lihat Semua",
                  isAction: true,
                  onTap: () => setState(() => _expandContact = !_expandContact),
                ),
                if (_expandContact)
                  ...draft.contacts.map(
                    (e) => _buildDataCard(title: e.name, subtitle: e.phone),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          // --- Tombol Simpan & Ajukan ---
          if (!widget.isViewOnly)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              setState(() => _isSubmitting = true);
                              // In edit mode, this is "Update"
                              final customerId = await form.submit();
                              if (mounted) {
                                if (customerId != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Data customer berhasil diupdate.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Gagal mengupdate data. Silakan coba lagi.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                setState(() => _isSubmitting = false);
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF5D5FEF)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Update",
                              style: TextStyle(color: Color(0xFF5D5FEF)),
                            ),
                    ),
                  ),

                  // Show "Ajukan" only for Draft status
                  if (status == 1) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                setState(() => _isSubmitting = true);
                                final customerId = await form.submit();
                                if (mounted) {
                                  if (customerId != null) {
                                    final approvalSuccess = await form
                                        .requestApproval(customerId);
                                    if (mounted) {
                                      if (approvalSuccess) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Data customer berhasil diajukan.'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.of(context).popUntil(
                                            (route) => route.isFirst);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Gagal meminta persetujuan. Silakan coba lagi.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Gagal mengajukan data. Silakan coba lagi.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  setState(() => _isSubmitting = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF5D5FEF),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                "Ajukan",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===================== STATUS ======================
  Map<String, dynamic> _getStatusInfo(int status) {
    switch (status) {
      case 1: // Draft
        return {'text': 'Draft', 'color': Colors.blueGrey, 'bg': Colors.blueGrey.shade100};
      case 2: // In Approval
        return {'text': 'In Approval', 'color': Colors.orange, 'bg': Colors.orange.shade100};
      case 3: // Revision
        return {'text': 'Revision', 'color': Colors.purple, 'bg': Colors.purple.shade100};
      case 4: // Approved
        return {'text': 'Approved', 'color': Colors.green, 'bg': Colors.green.shade100};
      case 9: // Rejected
        return {'text': 'Rejected', 'color': Colors.red, 'bg': Colors.red.shade100};
      default:
        return {'text': 'Unknown', 'color': Colors.grey, 'bg': Colors.grey.shade200};
    }
  }

  Widget _statusChip(int status) {
    final statusInfo = _getStatusInfo(status);
    final color = statusInfo['color'] as Color;
    final bg = statusInfo['bg'] as Color;
    final text = statusInfo['text'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // Widget pembantu untuk header section
  Widget _buildSectionHeader(
    String title,
    String actionText, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          if (isAction)
            InkWell(
              onTap: onTap,
              child: Text(
                actionText,
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            )
          else
            Text(
              actionText,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  // Widget info card (untuk detail customer)
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Widget data card (NPWP, Alamat, dll)
  Widget _buildDataCard({
    required String title,
    required String subtitle,
    String? content,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (content != null) ...[
            const Divider(),
            Text(
              content,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestrictionCard(String title, bool isAllowed) {
    return _buildDataCard(
      title: title,
      subtitle: isAllowed ? "Diizinkan" : "Dibatasi",
      trailing: Icon(
        isAllowed ? Icons.check_circle : Icons.cancel,
        color: isAllowed ? Colors.green : Colors.red,
        size: 20,
      ),
    );
  }
}
