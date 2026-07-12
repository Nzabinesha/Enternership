import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/opportunity.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();
  final _cohortCtrl = TextEditingController();
  List<String> _selectedSkills = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _bioCtrl.text = user.bio ?? '';
      _linkedinCtrl.text = user.linkedinUrl ?? '';
      _portfolioCtrl.text = user.portfolioUrl ?? '';
      _cohortCtrl.text = user.cohort ?? '';
      _selectedSkills = List.from(user.skills);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
    _cohortCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).value!;
      await ref.read(authRepositoryProvider).updateProfile(user.copyWith(
            fullName: _nameCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            skills: _selectedSkills,
            cohort: _cohortCtrl.text.trim().isEmpty
                ? null
                : _cohortCtrl.text.trim(),
            linkedinUrl: _linkedinCtrl.text.trim().isEmpty
                ? null
                : _linkedinCtrl.text.trim(),
            portfolioUrl: _portfolioCtrl.text.trim().isEmpty
                ? null
                : _portfolioCtrl.text.trim(),
          ));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cohortCtrl,
                decoration: const InputDecoration(
                    labelText: 'ALU cohort',
                    prefixIcon: Icon(Icons.school_outlined),
                    hintText: 'e.g. Class of 2026'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 4,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell startups a bit about yourself...',
                    alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              Text('Skills', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Select skills that represent your abilities',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Opportunity.skills.map((s) {
                  final sel = _selectedSkills.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: sel,
                    onSelected: (_) => setState(() => sel
                        ? _selectedSkills.remove(s)
                        : _selectedSkills.add(s)),
                    selectedColor: AppColors.primary.withOpacity(0.12),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color:
                            sel ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 12),
                    side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.divider),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Links', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkedinCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                    labelText: 'LinkedIn URL', prefixIcon: Icon(Icons.link)),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !v.startsWith('http')) {
                    return 'Include https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portfolioCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                    labelText: 'Portfolio / GitHub URL',
                    prefixIcon: Icon(Icons.web_outlined)),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !v.startsWith('http')) {
                    return 'Include https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
