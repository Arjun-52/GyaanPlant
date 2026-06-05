class TicketAuthorModel {
  final String? dbId; // _id
  final String? name;
  final String? email;
  final String? role;
  final String? avatar;
  final DateTime? createdAt;
  final bool? isLocked;
  final bool? isGoogleLinked;
  final String? id;

  TicketAuthorModel({
    this.dbId,
    this.name,
    this.email,
    this.role,
    this.avatar,
    this.createdAt,
    this.isLocked,
    this.isGoogleLinked,
    this.id,
  });

  factory TicketAuthorModel.fromJson(Map<String, dynamic> json) {
    return TicketAuthorModel(
      dbId: json['_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      avatar: json['avatar']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      isLocked: json['isLocked'] as bool?,
      isGoogleLinked: json['isGoogleLinked'] as bool?,
      id: json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': dbId,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
      'isLocked': isLocked,
      'isGoogleLinked': isGoogleLinked,
      'id': id,
    };
  }
}

class ReplyAuthorModel {
  final String? dbId; // _id
  final String? name;
  final String? email;
  final String? role;
  final String? avatar;
  final bool? isLocked;
  final bool? isGoogleLinked;
  final String? id;

  ReplyAuthorModel({
    this.dbId,
    this.name,
    this.email,
    this.role,
    this.avatar,
    this.isLocked,
    this.isGoogleLinked,
    this.id,
  });

  factory ReplyAuthorModel.fromJson(Map<String, dynamic> json) {
    return ReplyAuthorModel(
      dbId: json['_id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      avatar: json['avatar']?.toString(),
      isLocked: json['isLocked'] as bool?,
      isGoogleLinked: json['isGoogleLinked'] as bool?,
      id: json['id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': dbId,
      'name': name,
      'email': email,
      'role': role,
      'avatar': avatar,
      'isLocked': isLocked,
      'isGoogleLinked': isGoogleLinked,
      'id': id,
    };
  }
}

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] is int ? json['total'] as int : int.tryParse(json['total'].toString()) ?? 0,
      page: json['page'] is int ? json['page'] as int : int.tryParse(json['page'].toString()) ?? 1,
      limit: json['limit'] is int ? json['limit'] as int : int.tryParse(json['limit'].toString()) ?? 10,
      totalPages: json['totalPages'] is int ? json['totalPages'] as int : int.tryParse(json['totalPages'].toString()) ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrev: json['hasPrev'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}

class TicketReplyModel {
  final String? dbId; // _id
  final String id;
  final String text;
  final String? attachment;
  final bool isAgent;
  final DateTime createdAt;
  final ReplyAuthorModel? author;

  TicketReplyModel({
    this.dbId,
    required this.id,
    required this.text,
    this.attachment,
    required this.isAgent,
    required this.createdAt,
    this.author,
  });

  factory TicketReplyModel.fromJson(Map<String, dynamic> json) {
    ReplyAuthorModel? authorObj;
    if (json['author'] != null) {
      if (json['author'] is Map<String, dynamic>) {
        authorObj = ReplyAuthorModel.fromJson(json['author'] as Map<String, dynamic>);
      } else {
        authorObj = ReplyAuthorModel(name: json['author'].toString(), id: json['author'].toString());
      }
    }

    return TicketReplyModel(
      dbId: json['_id']?.toString(),
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      text: (json['text'] ?? json['message'] ?? '').toString(),
      attachment: json['attachment']?.toString(),
      isAgent: json['isAgent'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      author: authorObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': dbId,
      'id': id,
      'text': text,
      'attachment': attachment,
      'isAgent': isAgent,
      'createdAt': createdAt.toIso8601String(),
      'author': author?.toJson(),
    };
  }

  // Compatibility helper getters for old UI variables
  String get message => text;
  DateTime get timestamp => createdAt;
  String get sender => isAgent ? 'support' : 'student';
}

class TicketModel {
  final String? dbId; // _id
  final String ticketId;
  final String subject;
  final String type;
  final String priority;
  final String status;
  final String description;
  final String? attachment;
  final List<TicketReplyModel> replies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String id;
  final TicketAuthorModel? author;

  TicketModel({
    this.dbId,
    required this.ticketId,
    required this.subject,
    required this.type,
    required this.priority,
    required this.status,
    required this.description,
    this.attachment,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.author,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    var repliesList = <TicketReplyModel>[];
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .map((r) => TicketReplyModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    TicketAuthorModel? authorObj;
    if (json['author'] != null) {
      if (json['author'] is Map<String, dynamic>) {
        authorObj = TicketAuthorModel.fromJson(json['author'] as Map<String, dynamic>);
      } else {
        authorObj = TicketAuthorModel(name: json['author'].toString(), id: json['author'].toString());
      }
    }

    final parsedId = (json['ticketId'] ?? json['id'] ?? json['_id'] ?? '').toString();

    return TicketModel(
      dbId: json['_id']?.toString(),
      ticketId: parsedId,
      subject: (json['subject'] ?? '').toString(),
      type: (json['type'] ?? json['category'] ?? 'General').toString(),
      priority: (json['priority'] ?? 'Normal').toString(),
      status: (json['status'] ?? 'Open').toString(),
      description: (json['description'] ?? '').toString(),
      attachment: json['attachment']?.toString(),
      replies: repliesList,
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()) : DateTime.now(),
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      author: authorObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': dbId,
      'ticketId': ticketId,
      'subject': subject,
      'type': type,
      'priority': priority,
      'status': status,
      'description': description,
      'attachment': attachment,
      'replies': replies.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'id': id,
      'author': author?.toJson(),
    };
  }

  // Compatibility helper getters
  String get category => type;

  List<TicketReplyModel> get messages {
    final list = <TicketReplyModel>[];
    list.add(
      TicketReplyModel(
        id: ticketId,
        text: description,
        isAgent: false,
        author: author != null ? ReplyAuthorModel(role: author!.role, name: author!.name, id: author!.id) : null,
        createdAt: createdAt,
      ),
    );
    list.addAll(replies);
    return list;
  }
}

class TicketDetailsModel {
  final String? dbId; // _id
  final String ticketId;
  final String subject;
  final String type;
  final String priority;
  final String status;
  final String description;
  final String? attachment;
  final List<TicketReplyModel> replies;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? v; // __v
  final String id;
  final TicketAuthorModel? author;

  TicketDetailsModel({
    this.dbId,
    required this.ticketId,
    required this.subject,
    required this.type,
    required this.priority,
    required this.status,
    required this.description,
    this.attachment,
    required this.replies,
    required this.createdAt,
    required this.updatedAt,
    this.v,
    required this.id,
    this.author,
  });

  factory TicketDetailsModel.fromJson(Map<String, dynamic> json) {
    var repliesList = <TicketReplyModel>[];
    if (json['replies'] != null && json['replies'] is List) {
      repliesList = (json['replies'] as List)
          .map((r) => TicketReplyModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    TicketAuthorModel? authorObj;
    if (json['author'] != null) {
      if (json['author'] is Map<String, dynamic>) {
        authorObj = TicketAuthorModel.fromJson(json['author'] as Map<String, dynamic>);
      } else {
        authorObj = TicketAuthorModel(name: json['author'].toString(), id: json['author'].toString());
      }
    }

    final parsedId = (json['ticketId'] ?? json['id'] ?? json['_id'] ?? '').toString();

    return TicketDetailsModel(
      dbId: json['_id']?.toString(),
      ticketId: parsedId,
      subject: (json['subject'] ?? '').toString(),
      type: (json['type'] ?? json['category'] ?? 'General').toString(),
      priority: (json['priority'] ?? 'Normal').toString(),
      status: (json['status'] ?? 'Open').toString(),
      description: (json['description'] ?? '').toString(),
      attachment: json['attachment']?.toString(),
      replies: repliesList,
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()) : DateTime.now(),
      v: json['__v'] is int ? json['__v'] as int : int.tryParse(json['__v']?.toString() ?? ''),
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      author: authorObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': dbId,
      'ticketId': ticketId,
      'subject': subject,
      'type': type,
      'priority': priority,
      'status': status,
      'description': description,
      'attachment': attachment,
      'replies': replies.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'id': id,
      'author': author?.toJson(),
    };
  }

  // Compatibility helper getters
  String get category => type;

  List<TicketReplyModel> get messages {
    final list = <TicketReplyModel>[];
    list.add(
      TicketReplyModel(
        id: ticketId,
        text: description,
        isAgent: false,
        author: author != null ? ReplyAuthorModel(role: author!.role, name: author!.name, id: author!.id) : null,
        createdAt: createdAt,
      ),
    );
    list.addAll(replies);
    return list;
  }

  TicketModel toTicketModel() {
    return TicketModel(
      dbId: dbId,
      ticketId: ticketId,
      subject: subject,
      type: type,
      priority: priority,
      status: status,
      description: description,
      attachment: attachment,
      replies: replies,
      createdAt: createdAt,
      updatedAt: updatedAt,
      id: id,
      author: author,
    );
  }
}

class TicketsListResponse {
  final List<TicketModel> tickets;
  final PaginationModel pagination;

  TicketsListResponse({
    required this.tickets,
    required this.pagination,
  });

  factory TicketsListResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'] ?? json;
    List<TicketModel> ticketList = [];
    PaginationModel pagObj;

    if (dataNode is Map<String, dynamic>) {
      final ticketsVal = dataNode['tickets'] ?? dataNode['data'];
      if (ticketsVal is List) {
        ticketList = ticketsVal.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      
      final pagVal = dataNode['pagination'] ?? dataNode['meta'];
      if (pagVal is Map<String, dynamic>) {
        pagObj = PaginationModel.fromJson(pagVal);
      } else {
        pagObj = PaginationModel(
          total: ticketList.length,
          page: 1,
          limit: 10,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        );
      }
    } else if (dataNode is List) {
      ticketList = dataNode.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
      pagObj = PaginationModel(
        total: ticketList.length,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNext: false,
        hasPrev: false,
      );
    } else {
      pagObj = PaginationModel(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNext: false,
        hasPrev: false,
      );
    }

    return TicketsListResponse(
      tickets: ticketList,
      pagination: pagObj,
    );
  }
}

class TicketDetailsResponse {
  final TicketDetailsModel ticket;

  TicketDetailsResponse({required this.ticket});

  factory TicketDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['ticket'] as Map<String, dynamic>? ??
                 json['data'] as Map<String, dynamic>? ??
                 json;
    return TicketDetailsResponse(
      ticket: TicketDetailsModel.fromJson(data),
    );
  }
}

class AddReplyRequest {
  final String text;
  final String? attachment;

  AddReplyRequest({
    required this.text,
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (attachment != null) 'attachment': attachment,
    };
  }
}

class AddReplyResponse {
  final List<TicketReplyModel> replies;

  AddReplyResponse({required this.replies});

  factory AddReplyResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataNode = json['data'] ?? json;
    List<TicketReplyModel> replyList = [];
    if (dataNode is List) {
      replyList = dataNode.map((e) => TicketReplyModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (dataNode is Map<String, dynamic>) {
      final repliesVal = dataNode['replies'] ?? dataNode['data'];
      if (repliesVal is List) {
        replyList = repliesVal.map((e) => TicketReplyModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return AddReplyResponse(replies: replyList);
  }
}

class CreateTicketRequest {
  final String subject;
  final String type;
  final String priority;
  final String description;
  final String? attachment;

  CreateTicketRequest({
    required this.subject,
    required this.type,
    required this.priority,
    required this.description,
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'type': type,
      'priority': priority,
      'description': description,
      if (attachment != null) 'attachment': attachment,
    };
  }
}

class UpdateTicketStatusRequest {
  final String status;

  UpdateTicketStatusRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
