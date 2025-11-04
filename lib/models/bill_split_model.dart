import 'package:cloud_firestore/cloud_firestore.dart';

class BillSplitModel {
  final String id;
  final String title;
  final String description;
  final double totalAmount;
  final String creatorId;
  final String creatorName;
  final List<BillParticipant> participants;
  final String? billImageUrl;
  final DateTime createdAt;
  final BillStatus status;
  final String? splitType;
  final String? paymentId;
  final Map<String, String> chatMessages;

  BillSplitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.creatorId,
    required this.creatorName,
    required this.participants,
    this.billImageUrl,
    required this.createdAt,
    this.status = BillStatus.pending,
    this.splitType,
    this.paymentId,
    this.chatMessages = const {},
  });

  factory BillSplitModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BillSplitModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      creatorId: data['creator_id'] ?? '',
      creatorName: data['creator_name'] ?? '',
      participants: (data['participants'] as List<dynamic>?)
              ?.map((e) => BillParticipant.fromMap(e))
              .toList() ??
          [],
      billImageUrl: data['bill_image_url'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      status: BillStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BillStatus.pending,
      ),
      splitType: data['split_type'],
      paymentId: data['payment_id'],
      chatMessages: Map<String, String>.from(data['chat_messages'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'total_amount': totalAmount,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'participants': participants.map((e) => e.toMap()).toList(),
      'bill_image_url': billImageUrl,
      'created_at': Timestamp.fromDate(createdAt),
      'status': status.name,
      'split_type': splitType,
      'payment_id': paymentId,
      'chat_messages': chatMessages,
    };
  }

  double get amountPerPerson => totalAmount / participants.length;

  int get paidCount => participants.where((p) => p.hasPaid).length;

  int get pendingCount => participants.where((p) => !p.hasPaid).length;

  double get totalPaidAmount => participants
      .where((p) => p.hasPaid)
      .fold(0.0, (total, p) => total + p.shareAmount);

  double get totalPendingAmount => participants
      .where((p) => !p.hasPaid)
      .fold(0.0, (total, p) => total + p.shareAmount);
}

class BillParticipant {
  final String userId;
  final String userName;
  final String? userPhoto;
  final double shareAmount;
  final bool hasPaid;
  final DateTime? paidAt;
  final ParticipantStatus status;
  final String? rejectionReason;

  BillParticipant({
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.shareAmount,
    this.hasPaid = false,
    this.paidAt,
    this.status = ParticipantStatus.pending,
    this.rejectionReason,
  });

  factory BillParticipant.fromMap(Map<String, dynamic> data) {
    return BillParticipant(
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      userPhoto: data['user_photo'],
      shareAmount: (data['share_amount'] ?? 0).toDouble(),
      hasPaid: data['has_paid'] ?? false,
      paidAt: (data['paid_at'] as Timestamp?)?.toDate(),
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ParticipantStatus.pending,
      ),
      rejectionReason: data['rejection_reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_photo': userPhoto,
      'share_amount': shareAmount,
      'has_paid': hasPaid,
      'paid_at': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'status': status.name,
      'rejection_reason': rejectionReason,
    };
  }
}

enum BillStatus { pending, active, completed, cancelled, disputed }

enum ParticipantStatus { pending, accepted, rejected, paid }
