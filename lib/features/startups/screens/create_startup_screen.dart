import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/startup.dart';

class CreateStartupScreen extends ConsumerStatefulWidget {
  const CreateStartupScreen({super.key});

  @override
  ConsumerState<CreateStartupScreen> createState() =>
      _CreateStartupScreenState();
}

class _CreateStartupScreenState extends ConsumerState<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _cohortCtrl = TextEditingController();
  final _regIdCtrl = TextEditingController();
  String _industry = Startup.industries.first;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _descCtrl.dispose();
    _websiteCtrl.dispose();
    _cohortCtrl.dispose();
    _regIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).value!;
      final startup = Startup(
        id: '',
        founderId: user.uid,
        name: _nameCtrl.text.trim(),
        tagline: _taglineCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        industry: _industry,
        websiteUrl:
            _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
        aluCohort:
            _cohortCtrl.text.trim().isEmpty ? null : _cohortCtrl.text.trim(),
        aluRegistrationId:
            _regIdCtrl.text.trim().isEmpty ? null : _regIdCtrl.text.trim(),
        createdAt: DateTime.now(),
        isVerified: false,
      );
      await ref.read(startupRepositoryProvider).createStartup(startup);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Startup created! Verification is pending.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Register startup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your startup will be reviewed by ALU admin before appearing on the platform. Provide accurate details.',
                        style: TextStyle(fontSize: 12, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Startup name *',
                    prefixIcon: Icon(Icons.business_outlined)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taglineCtrl,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tagline *',
                  hintText: 'One line that captures what you do',
                  prefixIcon: Icon(Icons.short_text),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _industry,
                decoration: const InputDecoration(
                    labelText: 'Industry *',
                    prefixIcon: Icon(Icons.category_outlined)),
                items: Startup.industries
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: (v) => setState(() => _industry = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                maxLength: 600,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText:
                      'What problem are you solving? Who is your target market?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 50)
                    ? 'At least 50 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _websiteCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                    labelText: 'Website URL (optional)',
                    prefixIcon: Icon(Icons.link)),
              ),
              const SizedBox(height: 24),
              Text('ALU Verification Details',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('These details are used to verify your startup with ALU.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cohortCtrl,
                decoration: const InputDecoration(
                    labelText: 'Founder ALU cohort',
                    hintText: 'e.g. Class of 2025',
                    prefixIcon: Icon(Icons.school_outlined)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'ALU Registration / Incubator ID (if any)',
                  prefixIcon: Icon(Icons.badge_outlined),
                  hintText: 'From your ALU startup registration',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit for verification'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
