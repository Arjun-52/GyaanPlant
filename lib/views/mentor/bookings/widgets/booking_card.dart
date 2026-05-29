import 'package:flutter/material.dart';
import 'package:gyaanplant/models/mentor_models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final String initials;
  final Color avatarColor;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const BookingCard({
    super.key,
    required this.booking,
    required this.initials,
    required this.avatarColor,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        /// gradient bg
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2A20), Color(0xFF0A1F18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      booking.college,
                      style: const TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),

              Text(
                "₹${booking.price}",
                style: const TextStyle(
                  color: Color(0xFF16C47F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ///  TIME AND TOPIC
          Row(
            children: [
              Text(
                "📅 ${booking.time}",
                style: const TextStyle(
                  color: Color(0xFFFFB020),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.topic,
                  style: const TextStyle(color: Colors.white38),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ///  BUTTONS OR STATUS BADGE
          if (booking.status == "pending")
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16C47F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Accept",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onDecline,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Text(
                          "Decline",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking.status == "accepted"
                        ? const Color(0xFF16C47F).withOpacity(0.15)
                        : booking.status == "completed"
                            ? Colors.blue.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: booking.status == "accepted"
                          ? const Color(0xFF16C47F)
                          : booking.status == "completed"
                              ? Colors.blue
                              : Colors.red,
                    ),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: booking.status == "accepted"
                          ? const Color(0xFF16C47F)
                          : booking.status == "completed"
                              ? Colors.blue
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
