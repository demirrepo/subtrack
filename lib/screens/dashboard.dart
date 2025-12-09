import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:subtrack/widgets/subscription_stat_card.dart';
import 'package:subtrack/widgets/subscriptions_list/subscription_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  final Color activeColor = const Color(0xFF0EB79E);
  final Color dueColor = const Color(0xFFDC890D);

  Stream<QuerySnapshot<Map<String, dynamic>>> _subscriptionsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('subscriptions')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header area
            Container(
              height: MediaQuery.of(context).size.height * 0.38,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF272831),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _subscriptionsStream(user.uid),
                builder: (context, snapshot) {
                  double totalSpending = 0.0;
                  int activeCount = 0;
                  int dueCount = 0;

                  if (snapshot.hasData) {
                    for (final doc in snapshot.data!.docs) {
                      final data = doc.data();
                      final int priceCents =
                          (data['priceUsdCents'] is int)
                              ? data['priceUsdCents']
                              : (data['priceUsdCents'] ?? 0);
                      totalSpending += priceCents / 100.0;
                      final status =
                          (data['status'] ?? 'active').toString().toLowerCase();
                      if (status == 'due' || status == 'overdue') dueCount++;
                      if (status == 'active') activeCount++;
                    }
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 65),
                      Text(
                        '\$ ${totalSpending.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total spending',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 13),

                                // 1. Active subs card
                                Expanded(
                                  flex: 2,
                                  child: SubscriptionStatCard.stat(
                                    count: activeCount,
                                    label: 'ACTIVE \nSUBS',
                                    color: activeColor,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                //2. Due subs card
                                Expanded(
                                  flex: 2,
                                  child: SubscriptionStatCard.stat(
                                    count: dueCount,
                                    label: 'DUE \nSUBS',
                                    color: dueColor,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // 3. Add button
                                Expanded(
                                  flex: 1,
                                  child: SubscriptionStatCard.addButton(),
                                ),
                                const SizedBox(width: 13),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Your subscriptions',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // list area
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _subscriptionsStream(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No subscriptions yet',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      return SubscriptionItem(
                        data: data,
                        onTap: () {
                          // TODO: navigate to subscription details page
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
