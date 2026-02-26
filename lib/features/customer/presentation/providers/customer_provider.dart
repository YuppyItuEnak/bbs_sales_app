import 'package:bbs_sales_app/data/models/customer/add_customer_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_group_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_model.dart';
import 'package:bbs_sales_app/data/models/customer/delivery_area_model.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/services/customer/customer_repository.dart';
import 'package:bbs_sales_app/data/services/customer/delivery_area_repository.dart';
import 'package:bbs_sales_app/data/services/general/m_gen_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerFormProvider extends ChangeNotifier {
  final CustomerRepository _customerRepository = CustomerRepository();
  final MGenRepository _mGenRepository = MGenRepository();
  final DeliveryAreaRepository _deliveryAreaRepository =
      DeliveryAreaRepository();
  CustomerDraft draft = CustomerDraft();

  List<CustomerGroup> customerGroups = [];
  bool isLoadingCustomerGroups = false;
  List<MGenModel> prefixes = [];
  bool isLoadingPrefixes = false;
  CustomerGroup? parentCustomer;
  MGenModel? prefix;
  List<MGenModel> tops = [];
  bool isLoadingTops = false;
  MGenModel? top;

  String? taxable;
  String? cpName;
  String? cpPhone;
  String? salesAreaCode;
  String? salesAreaName;
  String? salesAreaId;
  String? notes;
  String? name;
  String? salesId;

  // Hold the full customer object when editing
  CustomerModel? _editingCustomer;
  CustomerModel? get editingCustomer => _editingCustomer;

  final String token;
  final String unitBusinessId;

  CustomerFormProvider({required this.token, required this.unitBusinessId}) {
    if (token.isNotEmpty) {
      _loadSalesData();
      fetchCustomerGroups();
      fetchPrefixOptions();
      fetchTopOptions();
    }
  }

  Future<void> _loadSalesData() async {
    final prefs = await SharedPreferences.getInstance();
    salesId = prefs.getString('sales_id');
    salesAreaId = prefs.getString('sales_area_id');
  }

  /// Reset all form fields to their initial state.
  void clear() {
    draft = CustomerDraft();
    parentCustomer = null;
    prefix = null;
    top = null;
    taxable = null;
    cpName = null;
    cpPhone = null;
    salesAreaCode = null;
    salesAreaName = null;
    notes = null;
    name = null;
    _editingCustomer = null;
    notifyListeners();
  }

  /// Load data from a CustomerModel into the provider for editing.
  void loadCustomerForEdit(CustomerModel customer) {
    _editingCustomer = customer;

    name = customer.name;
    cpName = customer.contact_person;
    cpPhone = customer.phone;
    notes = customer.notes;
    taxable = (customer.pn ?? false) ? "YA" : "TIDAK";

    parentCustomer = customerGroups.firstWhere(
      (g) => g.id == customer.group_id,
      orElse: () => CustomerGroup(
        id: customer.group_id ?? '',
        name: "Unknown Group",
        code: '',
        unitBussinessId:
            customer.unit_bussiness_id ?? '', // Added unitBussinessId
      ),
    );
    prefix = prefixes.firstWhere(
      (p) => p.id == customer.name_type_id,
      orElse: () => MGenModel(
        id: customer.name_type_id ?? '',
        value1: "Unknown",
        group: 'm_partner_type',
      ),
    );
    top = tops.firstWhere(
      (t) => t.id == customer.top_id,
      orElse: () => MGenModel(
        id: customer.top_id ?? '',
        value1: "Unknown",
        group: 'm_top_customer',
      ),
    );

    final restriction = customer.restrictions.isNotEmpty
        ? customer.restrictions.first
        : null;

    draft = CustomerDraft(
      name: customer.name ?? "",
      email: customer.email,
      phone: customer.phone,
      npwps: customer.npwps
          .map(
            (e) => CustomerNPWP(
              number: e.number ?? '',
              name: e.name ?? '',
              address: e.address ?? '',
              isDefault: e.is_default ?? false,
            ),
          )
          .toList(),
      addresses: customer.addresses
          .map(
            (e) => CustomerAddressModel(
              label: e.name ?? '',
              fullAddress: e.address ?? '',
              provinceId: e.province_id,
              cityId: e.city_id,
              districtId: e.district_id,
              deliveryAreaId: e.delivery_area_id,
              postalCode: int.tryParse(e.postal_code ?? ''),
              isDefault: e.is_default ?? false,
            ),
          )
          .toList(),
      banks: customer.accounts
          .map(
            (e) => CustomerBank(
              accountNumber: e.number ?? '',
              accountName: e.name ?? '',
              bankId: e.bank_id,
              areaCode: e.area_code,
              isDefault: e.is_default ?? false,
              bank: '',
            ),
          )
          .toList(),
      contacts: customer.phones
          .map(
            (e) =>
                CustomerContactModel(name: e.name ?? '', phone: e.phone ?? ''),
          )
          .toList(),
      favoriteItems: customer.itemFavs
          .map((e) => CustomerFavoriteItem(itemId: e.item_id ?? '', name: ''))
          .toList(),
      allowQuotation: restriction?.is_sq ?? true,
      allowOrder: restriction?.is_so ?? true,
      allowDelivery: restriction?.is_do ?? true,
      allowInvoice: restriction?.is_si ?? true,
      allowReturn: restriction?.is_sr ?? true,
    );

    notifyListeners();
  }

  Future<void> fetchCustomerGroups() async {
    isLoadingCustomerGroups = true;
    notifyListeners();

    try {
      customerGroups = await _customerRepository.fetchCustomerGroups(
        token: token,
        unitBusinessId: unitBusinessId,
      );
    } catch (e) {
      print('Error fetching customer groups: $e');
    }

    isLoadingCustomerGroups = false;
    notifyListeners();
  }

  Future<void> fetchPrefixOptions() async {
    isLoadingPrefixes = true;
    notifyListeners();

    try {
      prefixes = await _mGenRepository.fetchMGen('group=m_partner_type', token);
    } catch (e) {
      print('Error fetching type prefixes: $e');
    }

    isLoadingPrefixes = false;
    notifyListeners();
  }

  Future<void> fetchTopOptions() async {
    isLoadingTops = true;
    notifyListeners();

    try {
      tops = await _mGenRepository.fetchMGen('group=m_top_customer', token);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching ToP options: $e');
      }
    }

    isLoadingTops = false;
    notifyListeners();
  }

  Future<List<MGenModel>> fetchMGenData(String group, {String? key1}) async {
    try {
      String whereClause = 'group=$group';
      if (key1 != null) {
        whereClause += '|key1=$key1';
      }
      return await _mGenRepository.fetchMGen(whereClause, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching MGen data for group $group with key1 $key1: $e');
      }
      return [];
    }
  }

  Future<List<MGenModel>> fetchProvinces() async {
    return fetchMGenData('m_province');
  }

  Future<List<MGenModel>> fetchCities(String provinceId) async {
    return fetchMGenData('m_city', key1: provinceId);
  }

  Future<List<MGenModel>> fetchDistricts(String cityId) async {
    return fetchMGenData('m_district', key1: cityId);
  }

  Future<List<DeliveryAreaModel>> searchDeliveryAreas(String query) async {
    try {
      return await _deliveryAreaRepository.fetchDeliveryAreas(
        token: token,
        unitBusinessId: unitBusinessId,
        search: query,
      );
    } catch (e) {
      return [];
    }
  }

  void setParentCustomer(CustomerGroup? v) {
    parentCustomer = v;
    notifyListeners();
  }

  void setPrefix(MGenModel? v) {
    prefix = v;
    notifyListeners();
  }

  void setTop(MGenModel? v) {
    top = v;
    notifyListeners();
  }

  void setTaxable(String? v) {
    taxable = v;
    notifyListeners();
  }

  void setCpName(String v) {
    cpName = v;
    notifyListeners();
  }

  void setCpPhone(String v) {
    cpPhone = v;
    notifyListeners();
  }

  void setSalesAreaId(String? v) {
    salesAreaId = v;
    notifyListeners();
  }

  void setSalesAreaCode(String? v) {
    salesAreaCode = v;
    notifyListeners();
  }

  void setSalesAreaName(String? v) {
    salesAreaName = v;
    notifyListeners();
  }

  void setNotes(String v) {
    notes = v;
    notifyListeners();
  }

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setEmail(String v) {
    draft.email = v;
    notifyListeners();
  }

  void setPhone(String v) {
    draft.phone = v;
    notifyListeners();
  }

  void addNPWP(CustomerNPWP npwp) {
    if (npwp.isDefault) {
      for (var n in draft.npwps) {
        n.isDefault = false;
      }
    }
    draft.npwps.add(npwp);
    notifyListeners();
  }

  void removeNPWP(String id) {
    draft.npwps.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void saveAddress({
    String? id,
    required String label,
    required String address,
    String? provinceId,
    String? cityId,
    String? districtId,
    String? deliveryAreaId,
    int? postalCode,
    required bool isDefault,
  }) {
    if (isDefault) {
      for (var a in draft.addresses) {
        a.isDefault = false;
      }
    }

    if (id != null) {
      final index = draft.addresses.indexWhere((e) => e.id == id);
      if (index != -1) {
        draft.addresses[index] = CustomerAddressModel(
          id: id,
          label: label,
          fullAddress: address,
          provinceId: provinceId,
          cityId: cityId,
          districtId: districtId,
          deliveryAreaId: deliveryAreaId,
          postalCode: postalCode,
          isDefault: isDefault,
        );
      }
    } else {
      draft.addresses.add(
        CustomerAddressModel(
          id: const Uuid().v4(),
          label: label,
          fullAddress: address,
          provinceId: provinceId,
          cityId: cityId,
          districtId: districtId,
          deliveryAreaId: deliveryAreaId,
          postalCode: postalCode,
          isDefault: isDefault,
        ),
      );
    }
    notifyListeners();
  }

  void removeAddress(String id) {
    draft.addresses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addBank({
    required String bankName,
    required String accountNumber,
    required String accountName,
    String? bankId,
    String? areaCode,
    required bool isDefault,
  }) {
    if (isDefault) {
      for (var b in draft.banks) {
        b.isDefault = false;
      }
    }
    draft.banks.add(
      CustomerBank(
        id: const Uuid().v4(),
        bank: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        bankId: bankId,
        areaCode: areaCode,
        isDefault: isDefault,
      ),
    );
    notifyListeners();
  }

  void removeBank(String id) {
    draft.banks.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addContact() {
    draft.contacts.add(CustomerContactModel(id: const Uuid().v4()));
    notifyListeners();
  }

  void updateContact(String id, {String? name, String? phone}) {
    final index = draft.contacts.indexWhere((e) => e.id == id);
    if (index != -1) {
      final old = draft.contacts[index];
      draft.contacts[index] = CustomerContactModel(
        id: id,
        name: name ?? old.name,
        phone: phone ?? old.phone,
      );
      notifyListeners();
    }
  }

  void removeContact(String id) {
    draft.contacts.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addDocument({required String type, String? note}) {
    draft.documents.add(
      CustomerDocument(id: const Uuid().v4(), type: type, note: note),
    );
    notifyListeners();
  }

  void removeDocument(String id) {
    draft.documents.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addFavorite(dynamic item) {
    draft.favoriteItems.add(
      CustomerFavoriteItem(
        id: const Uuid().v4(),
        itemId: item.id,
        name: item.name,
      ),
    );
    notifyListeners();
  }

  void removeFavorite(String id) {
    draft.favoriteItems.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setRestriction({
    bool? quotation,
    bool? order,
    bool? delivery,
    bool? invoice,
    bool? returned,
  }) {
    if (quotation != null) draft.allowQuotation = quotation;
    if (order != null) draft.allowOrder = order;
    if (delivery != null) draft.allowDelivery = delivery;
    if (invoice != null) draft.allowInvoice = invoice;
    if (returned != null) draft.allowReturn = returned;
    notifyListeners();
  }

  Future<String?> submit() async {
    if (salesId == null || salesAreaId == null) await _loadSalesData();

    final model = draft.toModel(
      topId: top?.id,
      nameTypeId: prefix?.id,
      groupId: parentCustomer?.id,
      pn: taxable == "YA",
      salesAreaId: salesAreaId,
      salesId: salesId,
      unitBusinessId: unitBusinessId,
      contactPerson: cpName ?? "",
      notes: notes ?? "",
      name: name ?? "",
      createdBy: salesId,
      updatedBy: salesId,
    );

    try {
      // If we are editing, we should call an update method instead of create
      if (_editingCustomer != null) {
        // TODO: Implement update customer in repository
        // final data = await _customerRepository.updateCustomer(
        //   token: token,
        //   customerId: _editingCustomer!.id,
        //   data: model,
        // );
        // return data['id'];
        print("UPDATE LOGIC NOT IMPLEMENTED YET");
        return _editingCustomer!.id; // Placeholder
      } else {
        final data = await _customerRepository.createCustomer(
          token: token,
          data: model,
        );
        return data['id'];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Submit Error: $e");
      }
      return null;
    }
  }

  Future<bool> requestApproval(String customerId) async {
    try {
      await _customerRepository.requestApproval(
        token: token,
        customerId: customerId,
        unitBusinessId: unitBusinessId,
      );
      return true;
    } catch (e) {
      print("Request Approval Error: $e");
      return false;
    }
  }
}

class CustomerDraft {
  String name;
  String? email;
  String? phone;

  List<CustomerNPWP> npwps = [];
  List<CustomerAddressModel> addresses = [];
  List<CustomerBank> banks = [];
  List<CustomerContactModel> contacts = [];
  List<CustomerDocument> documents = [];
  List<CustomerFavoriteItem> favoriteItems = [];

  bool allowQuotation = true;
  bool allowOrder = true;
  bool allowDelivery = true;
  bool allowInvoice = true;
  bool allowReturn = true;

  CustomerDraft({
    this.name = "",
    this.email,
    this.phone,
    this.npwps = const [],
    this.addresses = const [],
    this.banks = const [],
    this.contacts = const [],
    this.documents = const [],
    this.favoriteItems = const [],
    this.allowQuotation = true,
    this.allowOrder = true,
    this.allowDelivery = true,
    this.allowInvoice = true,
    this.allowReturn = true,
  });

  AddCustomerModel toModel({
    String? topId,
    String? nameTypeId,
    String? groupId,
    bool pn = true,
    String? salesAreaId,
    String? salesId,
    required String unitBusinessId,
    required String contactPerson,
    required String notes,
    required String name,
    String? createdBy,
    String? updatedBy,
  }) {
    return AddCustomerModel(
      name: name,
      email: email,
      phone: phone ?? "",
      topId: topId,
      nameTypeId: nameTypeId,
      groupId: groupId,
      pn: pn,
      coaId: "650e6ac3-c9b3-4f66-ad8e-25262bab57a0",
      currentApprovalLevel: 1,
      approvalCount: 0,
      approvedCount: 0,
      status: 1,
      salesAreaId: salesAreaId,
      salesId: salesId,
      unitBussinessId: unitBusinessId,
      contactPerson: contactPerson,
      notes: notes,
      createdBy: createdBy,
      updatedBy: updatedBy,
      npwps: npwps
          .map(
            (e) => CustomerNPWPRequest(
              number: e.number,
              name: e.name,
              address: e.address,
              isDefault: e.isDefault,
              isActive: true,
            ),
          )
          .toList(),
      accounts: banks
          .map(
            (e) => CustomerAccountRequest(
              name: e.accountName,
              number: e.accountNumber,
              bankId: e.bankId,
              areaCode: e.areaCode,
              isDefault: e.isDefault,
              isActive: true,
            ),
          )
          .toList(),
      addresses: addresses
          .map(
            (e) => CustomerAddressRequest(
              name: e.label,
              address: e.fullAddress,
              provinceId: e.provinceId,
              cityId: e.cityId,
              districtId: e.districtId,
              deliveryAreaId: e.deliveryAreaId,
              postalCode: e.postalCode.toString(),
              isDefault: e.isDefault,
              isActive: true,
            ),
          )
          .toList(),
      phones: contacts
          .map((e) => CustomerPhoneRequest(name: e.name, phone: e.phone))
          .toList(),
      docs: documents.map((e) => CustomerDocRequest(notes: e.note)).toList(),
      itemFavs: favoriteItems
          .map((e) => CustomerItemFavRequest(itemId: e.itemId))
          .toList(),
      restrictions: [
        CustomerRestrictionRequest(
          isSq: allowQuotation,
          isSo: allowOrder,
          isDo: allowDelivery,
          isSi: allowInvoice,
          isSr: allowReturn,
        ),
      ],
    );
  }
}

class CustomerNPWP {
  final String? id;
  final String number;
  final String name;
  final String address;
  bool isDefault;
  CustomerNPWP({
    String? id,
    required this.number,
    required this.name,
    required this.address,
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();
}

class CustomerAddressModel {
  final String? id;
  final String label;
  final String fullAddress;
  final String? provinceId;
  final String? cityId;
  final String? districtId;
  final String? deliveryAreaId;
  final int? postalCode;
  bool isDefault;
  CustomerAddressModel({
    this.id,
    required this.label,
    required this.fullAddress,
    this.provinceId,
    this.cityId,
    this.districtId,
    this.deliveryAreaId,
    this.postalCode,
    this.isDefault = false,
  });
  String get address => fullAddress;
  String get city => "";
}

class CustomerBank {
  final String? id;
  final String bank;
  final String accountNumber;
  final String accountName;
  final String? bankId;
  final String? areaCode;
  bool isDefault;
  CustomerBank({
    this.id,
    required this.bank,
    required this.accountNumber,
    required this.accountName,
    this.bankId,
    this.areaCode,
    this.isDefault = false,
  });
}

class CustomerContactModel {
  final String? id;
  final String name;
  final String phone;
  CustomerContactModel({this.id, this.name = "", this.phone = ""});
}

class CustomerDocument {
  final String? id;
  final String type;
  final String? note;
  CustomerDocument({this.id, required this.type, this.note});
}

class CustomerFavoriteItem {
  final String? id;
  final String itemId;
  final String name;
  CustomerFavoriteItem({this.id, required this.itemId, required this.name});
}
