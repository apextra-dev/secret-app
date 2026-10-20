import 'package:flutter/material.dart';

class ChatSelectionService extends ChangeNotifier {
  final Set<String> _selectedPartnerIds = {};

  Set<String> get selectedPartnerIds => _selectedPartnerIds;

  bool get isSelectionMode => _selectedPartnerIds.isNotEmpty;

  void toggleSelection(String partnerId) {
    if (_selectedPartnerIds.contains(partnerId)) {
      _selectedPartnerIds.remove(partnerId);
    } else {
      _selectedPartnerIds.add(partnerId);
    }
    notifyListeners(); 
  }

  void clearSelection() {
    _selectedPartnerIds.clear();
    notifyListeners();
  }
}
