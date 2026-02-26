import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_model.dart';
import 'package:bbs_sales_app/data/models/prospect/prospect_create_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_realization_detail_model.dart';
import 'package:bbs_sales_app/data/services/general/m_gen_repository.dart';
import 'package:bbs_sales_app/data/services/prospect/prospect_repository.dart';
import 'package:bbs_sales_app/data/services/visit/visit_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProspectProvider with ChangeNotifier {
  final VisitRepository _visitRepository = VisitRepository();
  final ProspectRepository _prospectRepository = ProspectRepository();
  final MGenRepository _mGenRepository = MGenRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  VisitRealizationDetail? _visitRealizationDetail;
  VisitRealizationDetail? get visitRealizationDetail => _visitRealizationDetail;

  List<CustomerModel> prospects = [];
  bool isLoadingProspects = false;

  // Form fields
  List<MGenModel> prefixes = [];
  bool isLoadingPrefixes = false;
  MGenModel? prefix;

  List<MGenModel> tops = [];
  bool isLoadingTops = false;
  MGenModel? top;

  String? taxable;
  String? cpName;
  String? cpPhone;
  String? notes;
  String? name;
  String? address;
  String? phone;

  String? salesId;
  String? unitBusinessId;

  Future<bool> performCheckout({
    required String realizationId,
    required Map<String, String> data,
    required String photoPath,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _visitRepository.checkOut(
        realizationId: realizationId,
        data: data,
        photoPath: photoPath,
        token: token,
      );
      if (success) {
        _visitRealizationDetail = await _visitRepository.fetchVisitDetail(
          realizationId,
          token,
        );
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProspect({
    required ProspectCreateModel prospect,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _prospectRepository.createProspect(
        prospect: prospect,
        token: token,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrefixOptions(String token) async {
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

  Future<void> fetchTopOptions(String token) async {
    isLoadingTops = true;
    notifyListeners();

    try {
      tops = await _mGenRepository.fetchMGen('group=m_top_customer', token);
    } catch (e) {
      print('Error fetching ToP options: $e');
    }

    isLoadingTops = false;
    notifyListeners();
  }

  Future<void> fetchListProspectName(String token) async {
    isLoadingProspects = true;
    notifyListeners();

    try {
      prospects = await _prospectRepository.fetchListProspect(
        token,
        salesId!,
        unitBusinessId: unitBusinessId!,
      );
    } catch (e) {
      print('Error fetching prospects: $e');
    }

    isLoadingProspects = false;
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

  void setNotes(String v) {
    notes = v;
    notifyListeners();
  }

  void setName(String v) {
    name = v;
    notifyListeners();
  }

  void setPhone(String v) {
    phone = v;
    notifyListeners();
  }

  void setAddress(String v) {
    address = v;
    notifyListeners();
  }
}
