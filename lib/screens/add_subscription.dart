import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/subscription_service.dart';

class AddSubscriptionPage extends StatefulWidget {
  const AddSubscriptionPage({super.key});

  @override
  State<AddSubscriptionPage> createState() => _AddSubscriptionPageState();
}

class _AddSubscriptionPageState extends State<AddSubscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _status = 'active';
  bool _isSaving = false;

  final _service = SubscriptionService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // price in dollars -> convert to cents
      final priceDouble = double.parse(_priceCtrl.text.trim());
      final priceCents = (priceDouble * 100).round();

      final id = await _service.addSubscription(
        userId: user.uid,
        subscriptionData: {
          'name': _nameCtrl.text.trim(),
          'priceUsdCents': priceCents,
          'status': _status,
          'startDateUtc': DateTime.now(),
          'nextBillDateUtc': DateTime.now(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved subscription (id: $id)')));
      Navigator.of(context).pop(true); // return true to indicate success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add subscription', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF272831),
      ),
      backgroundColor: const Color(0xFF1C1D24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF272831),
                  ),
                  validator:
                      (v) => (v ?? '').trim().isEmpty ? 'Enter name' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _priceCtrl,
                  style: GoogleFonts.inter(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Price (USD)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF272831),
                  ),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Enter price';
                    final parsed = double.tryParse(v!.trim());
                    if (parsed == null) return 'Enter valid number';
                    if (parsed < 0) return 'Price must be >= 0';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF272831),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _status,
                            items: const [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('active'),
                              ),
                              DropdownMenuItem(
                                value: 'due',
                                child: Text('due'),
                              ),
                              DropdownMenuItem(
                                value: 'overdue',
                                child: Text('overdue'),
                              ),
                            ],
                            onChanged:
                                (v) => setState(() => _status = v ?? 'active'),
                            dropdownColor: const Color(0xFF272831),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Next bill',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat.yMMMd().format(DateTime.now()),
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EB79E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Save subscription',
                            style: GoogleFonts.poppins(),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
