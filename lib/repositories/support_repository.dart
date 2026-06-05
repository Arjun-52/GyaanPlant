import 'package:flutter/foundation.dart';
import '../models/support/ticket_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';

class SupportRepository {
  final NetworkAPIManager _api;

  SupportRepository(this._api);

  Future<TicketsListResponse> getTickets({
    String? status,
    String? priority,
    String? type,
    String? date,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint("🎫 [SupportRepository] Requesting ticket list");
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (date != null && date.isNotEmpty) queryParams['date'] = date;
      if (searchQuery != null && searchQuery.isNotEmpty) queryParams['q'] = searchQuery;

      debugPrint("🎫 [SupportRepository] Filters applied: $queryParams");

      final response = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.tickets,
        queryParameters: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final res = TicketsListResponse.fromJson(response.data!);
        debugPrint("🎫 [SupportRepository] Ticket list loaded. Count: ${res.tickets.length}");
        return res;
      } else {
        final errorMsg = response.error?.message ?? 'Failed to load tickets';
        debugPrint("🎫 [SupportRepository] Error fetching tickets: $errorMsg");
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      debugPrint("🎫 [SupportRepository] Exception in getTickets: $e");
      debugPrint("Stack trace: $stack");
      rethrow;
    }
  }

  Future<TicketDetailsModel> getTicketDetails(String ticketId) async {
    try {
      debugPrint("🎫 [SupportRepository] Requesting ticket details: $ticketId");
      final response = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.ticketDetails(ticketId),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        debugPrint("🎫 [SupportRepository] Raw API response data: ${response.data}");
        final res = TicketDetailsResponse.fromJson(response.data!);
        debugPrint("🎫 [SupportRepository] Parsed TicketDetailsModel properties - ticketId: '${res.ticket.ticketId}', id: '${res.ticket.id}', dbId: '${res.ticket.dbId}'");
        return res.ticket;
      } else {
        final errorMsg = response.error?.message ?? 'Failed to load ticket details';
        debugPrint("🎫 [SupportRepository] Error fetching ticket details: $errorMsg");
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      debugPrint("🎫 [SupportRepository] Exception in getTicketDetails: $e");
      debugPrint("Stack trace: $stack");
      rethrow;
    }
  }

  Future<TicketModel> createTicket(CreateTicketRequest request) async {
    try {
      debugPrint("🎫 [SupportRepository] Creating ticket: ${request.subject}");
      final response = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.tickets,
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final res = TicketDetailsResponse.fromJson(response.data!);
        debugPrint("🎫 [SupportRepository] Ticket created successfully: ${res.ticket.ticketId}");
        return res.ticket.toTicketModel();
      } else {
        final errorMsg = response.error?.message ?? 'Failed to create ticket';
        debugPrint("🎫 [SupportRepository] Error creating ticket: $errorMsg");
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      debugPrint("🎫 [SupportRepository] Exception in createTicket: $e");
      debugPrint("Stack trace: $stack");
      rethrow;
    }
  }

  Future<List<TicketReplyModel>> addReply({
    required String ticketId,
    required String text,
    String? attachment,
  }) async {
    try {
      debugPrint("🎫 [SupportRepository] Adding reply to ticket: $ticketId");
      final request = AddReplyRequest(text: text, attachment: attachment);
      final response = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.ticketReply(ticketId),
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final res = AddReplyResponse.fromJson(response.data!);
        debugPrint("🎫 [SupportRepository] Reply added successfully. Total replies: ${res.replies.length}");
        return res.replies;
      } else {
        final errorMsg = response.error?.message ?? 'Failed to add reply';
        debugPrint("🎫 [SupportRepository] Error adding reply: $errorMsg");
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      debugPrint("🎫 [SupportRepository] Exception in addReply: $e");
      debugPrint("Stack trace: $stack");
      rethrow;
    }
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      debugPrint("🎫 [SupportRepository] Updating status for ticket: $ticketId to $status");
      final response = await _api.patch<void>(
        ApiEndpoints.ticketStatus(ticketId),
        data: UpdateTicketStatusRequest(status: status).toJson(),
      );

      if (response.success) {
        debugPrint("🎫 [SupportRepository] Status updated successfully for ticket: $ticketId");
      } else {
        final errorMsg = response.error?.message ?? 'Failed to update status';
        debugPrint("🎫 [SupportRepository] Error updating status: $errorMsg");
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      debugPrint("🎫 [SupportRepository] Exception in updateTicketStatus: $e");
      debugPrint("Stack trace: $stack");
      rethrow;
    }
  }
}
