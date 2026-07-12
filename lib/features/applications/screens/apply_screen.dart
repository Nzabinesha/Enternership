import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/application.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final String opportunityId;
  const ApplyScreen({super.key, required this.opportunityId});

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _coverCtrl.dispose();
    _portfolioCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).value!;
      final opp =
          ref.read(opportunityByIdProvider(widget.opportunityId)).value!;
      final app = Application(
        id: const Uuid().v4(),
        studentId: user.uid,
        studentName: user.fullName,
        studentPhotoUrl: user.photoUrl,
        opportunityId: widget.opportunityId,
        opportunityTitle: opp.title,
        startupId: opp.startupId,
        startupName: opp.startupName,
        coverLetter: _coverCtrl.text.trim(),
        portfolioUrl: _portfolioCtrl.text.trim().isEmpty
            ? null
            : _portfolioCtrl.text.trim(),
        appliedAt: DateTime.now(),
      );
      await ref.read(applicationRepositoryProvider).submitApplication(app);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        context.pop();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final oppAsync = ref.watch(opportunityByIdProvider(widget.opportunityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Apply')),
      body: oppAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (opp) {
          if (opp == null) return const Center(child: Text('Not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Opportunity summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Applying for',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(opp.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.primary)),
                        Text(opp.startupName,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Cover letter',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tell the startup why you\'re a great fit. Be specific about your skills and what you\'d bring to the team.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _coverCtrl,
                    maxLines: 10,
                    maxLength: 1500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'I\'m interested in this role because...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 100) {
                        return 'Write at least 100 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Portfolio / work samples (optional)',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _portfolioCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Link to portfolio, GitHub, or Behance',
                      prefixIcon: Icon(Icons.link),
                      hintText: 'https://...',
                    ),
                    validator: (v) {
                      if (v != null && v.isNotEmpty && !v.startsWith('http')) {
                        return 'Enter a valid URL starting with http(s)://';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Submit application'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your profile information will be shared with the startup.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
