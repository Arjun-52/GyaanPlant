import 'package:flutter/material.dart';
import '../../models/support/ticket_model.dart';
import '../../data/services/api_service.dart';

class SupportViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TicketModel> _tickets = [];
  PaginationModel? _pagination;
  
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Selected Ticket Details State
  TicketDetailsModel? _selectedTicketDetails;
  List<TicketReplyModel> _replies = [];
  bool _isLoadingDetails = false;
  String? _detailsErrorMessage;

  // Add reply state
  bool _isSendingReply = false;
  String? _replyError;

  // Current applied filters
  String? _statusFilter;
  String? _priorityFilter;
  String? _typeFilter;
  String? _dateFilter;
  String _searchQuery = "";

  List<TicketModel> get tickets => _tickets;
  PaginationModel? get pagination => _pagination;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  TicketDetailsModel? get selectedTicketDetails => _selectedTicketDetails;
  List<TicketReplyModel> get replies => _replies;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get detailsErrorMessage => _detailsErrorMessage;

  bool get isSendingReply => _isSendingReply;
  String? get replyError => _replyError;

  String? get statusFilter => _statusFilter;
  String? get priorityFilter => _priorityFilter;
  String? get typeFilter => _typeFilter;
  String? get dateFilter => _dateFilter;
  String get searchQuery => _searchQuery;

  // Fetch tickets from API
  Future<void> fetchTickets({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      debugPrint("🎫 [SupportViewModel] Refresh triggered");
    } else {
      _isLoading = true;
      _errorMessage = null;
      debugPrint("🎫 [SupportViewModel] Ticket list requested");
    }
    notifyListeners();

    try {
      debugPrint("🎫 [SupportViewModel] Filters applied: status=$_statusFilter, priority=$_priorityFilter, type=$_typeFilter, date=$_dateFilter, searchQuery=$_searchQuery");

      final res = await _apiService.support.getTickets(
        status: _statusFilter,
        priority: _priorityFilter,
        type: _typeFilter,
        date: _dateFilter,
        searchQuery: _searchQuery,
        page: 1,
        limit: 10,
      );

      _tickets = res.tickets;
      _pagination = res.pagination;
      _errorMessage = null;
      debugPrint("🎫 [SupportViewModel] Ticket list loaded. Count: ${_tickets.length}");
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint("🎫 [SupportViewModel] Error fetching tickets: $e");
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  // Fetch single ticket details
  Future<void> fetchTicketDetails(String ticketId, {bool isRefresh = false}) async {
    if (isRefresh) {
      debugPrint("🎫 [SupportViewModel] Refresh triggered for ticket details: $ticketId");
    } else {
      _selectedTicketDetails = null;
      _isLoadingDetails = true;
      _detailsErrorMessage = null;
      debugPrint("🎫 [SupportViewModel] Ticket details requested: $ticketId");
    }
    notifyListeners();

    try {
      debugPrint("🎫 [SupportViewModel] Before assignment: _selectedTicketDetails=$_selectedTicketDetails");
      final detail = await _apiService.support.getTicketDetails(ticketId);
      _selectedTicketDetails = detail;
      _replies = detail.replies;
      _detailsErrorMessage = null;
      debugPrint("🎫 [SupportViewModel] After assignment: _selectedTicketDetails=$_selectedTicketDetails");
    } catch (e) {
      _detailsErrorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint("🎫 [SupportViewModel] Error fetching ticket details: $e");
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // Load more / Pagination
  Future<void> loadMore() async {
    if (_isLoadingMore || _pagination == null || !_pagination!.hasNext) return;

    _isLoadingMore = true;
    debugPrint("🎫 [SupportViewModel] Pagination triggered. Loading page: ${_pagination!.page + 1}");
    notifyListeners();

    try {
      final nextPage = _pagination!.page + 1;
      final res = await _apiService.support.getTickets(
        status: _statusFilter,
        priority: _priorityFilter,
        type: _typeFilter,
        date: _dateFilter,
        searchQuery: _searchQuery,
        page: nextPage,
        limit: 10,
      );

      _tickets.addAll(res.tickets);
      _pagination = res.pagination;
      debugPrint("🎫 [SupportViewModel] Ticket list loaded (more). Current count: ${_tickets.length}");
    } catch (e) {
      debugPrint("🎫 [SupportViewModel] Error loading more tickets: $e");
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Apply filters and trigger fetch
  void applyFilters({
    String? status,
    String? priority,
    String? type,
    String? date,
    String? search,
  }) {
    _statusFilter = status;
    _priorityFilter = priority;
    _typeFilter = type;
    _dateFilter = date;
    if (search != null) {
      _searchQuery = search;
      debugPrint("🎫 [SupportViewModel] Search executed: $search");
    }
    fetchTickets();
  }

  // Clear all filters
  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _typeFilter = null;
    _dateFilter = null;
    _searchQuery = "";
    debugPrint("🎫 [SupportViewModel] Filters cleared");
    fetchTickets();
  }

  // Create/Raise a ticket
  Future<bool> createTicket({
    required String subject,
    required String category, // maps to type
    required String priority,
    required String description,
    String? attachment,
  }) async {
    debugPrint("🎫 [SupportViewModel] Requesting to create ticket: $subject");
    try {
      String mappedType = 'general';
      final catLower = category.toLowerCase();
      if (catLower.contains('technical')) {
        mappedType = 'technical';
      } else if (catLower.contains('billing') || catLower.contains('payment')) {
        mappedType = 'billing';
      }

      String mappedPriority = 'normal';
      final prioLower = priority.toLowerCase();
      if (prioLower.contains('low')) {
        mappedPriority = 'low';
      } else if (prioLower.contains('high')) {
        mappedPriority = 'high';
      } else if (prioLower.contains('urgent') || prioLower.contains('critical')) {
        mappedPriority = 'high';
      }

      final req = CreateTicketRequest(
        subject: subject,
        type: mappedType,
        priority: mappedPriority,
        description: description,
        attachment: attachment,
      );

      await _apiService.support.createTicket(req);
      debugPrint("🎫 [SupportViewModel] Ticket created successfully");
      fetchTickets();
      return true;
    } catch (e) {
      debugPrint("🎫 [SupportViewModel] Error creating ticket: $e");
      return false;
    }
  }

  // Submit a reply
  Future<bool> addReply(String ticketId, String text, {String? attachment}) async {
    debugPrint("🎫 [SupportViewModel] Requesting to add reply to ticket: $ticketId");
    _isSendingReply = true;
    _replyError = null;
    notifyListeners();

    try {
      final updatedReplies = await _apiService.support.addReply(
        ticketId: ticketId,
        text: text,
        attachment: attachment,
      );
      _replies = updatedReplies;
      
      // Also update selectedTicketDetails replies list
      if (_selectedTicketDetails != null) {
        _selectedTicketDetails = TicketDetailsModel(
          dbId: _selectedTicketDetails!.dbId,
          ticketId: _selectedTicketDetails!.ticketId,
          subject: _selectedTicketDetails!.subject,
          type: _selectedTicketDetails!.type,
          priority: _selectedTicketDetails!.priority,
          status: _selectedTicketDetails!.status,
          description: _selectedTicketDetails!.description,
          attachment: _selectedTicketDetails!.attachment,
          replies: updatedReplies,
          createdAt: _selectedTicketDetails!.createdAt,
          updatedAt: _selectedTicketDetails!.updatedAt,
          v: _selectedTicketDetails!.v,
          id: _selectedTicketDetails!.id,
          author: _selectedTicketDetails!.author,
        );
      }
      
      // Update in the tickets list too if present
      final index = _tickets.indexWhere((t) => t.ticketId == ticketId);
      if (index != -1 && _selectedTicketDetails != null) {
        _tickets[index] = _selectedTicketDetails!.toTicketModel();
      }
      _replyError = null;
      debugPrint("🎫 [SupportViewModel] Reply added successfully, state updated");
      notifyListeners();
      return true;
    } catch (e) {
      _replyError = e.toString().replaceAll('Exception: ', '');
      debugPrint("🎫 [SupportViewModel] Error adding reply: $e");
      notifyListeners();
      return false;
    } finally {
      _isSendingReply = false;
      notifyListeners();
    }
  }

  // Update status
  Future<bool> changeStatus(String ticketId, String status) async {
    debugPrint("🎫 [SupportViewModel] Requesting to update status for ticket: $ticketId to $status");
    try {
      await _apiService.support.updateTicketStatus(ticketId, status);
      debugPrint("🎫 [SupportViewModel] Status updated successfully");
      
      final updatedTicket = await _apiService.support.getTicketDetails(ticketId);
      _selectedTicketDetails = updatedTicket;

      final index = _tickets.indexWhere((t) => t.ticketId == ticketId);
      if (index != -1) {
        _tickets[index] = updatedTicket.toTicketModel();
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("🎫 [SupportViewModel] Error updating status: $e");
      return false;
    }
  }
}
