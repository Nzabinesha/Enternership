import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alu_enternership_pro/core/theme/app_theme.dart';
import 'package:alu_enternership_pro/providers/providers.dart';
import 'package:alu_enternership_pro/core/models/opportunity.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  final String startupId;
  const PostOpportunityScreen({super.key, required this.startupId});

  @override
  ConsumerState<PostOpportunityScreen> createState() =>
      _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _compensationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _role = Opportunity.roles.first;
  OpportunityType _type = OpportunityType.internship;
  bool _isPaid = false;
  bool _isRemote = false;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  List<String> _selectedSkills = [];
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _compensationCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final startup = ref.read(startupByIdProvider(widget.startupId)).value!;
      final opp = Opportunity(
        id: '',
        startupId: widget.startupId,
        startupName: startup.name,
        startupLogoUrl: startup.logoUrl,
        startupVerified: startup.isVerified,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        role: _role,
        type: _type,
        requiredSkills: _selectedSkills,
        duration: _durationCtrl.text.trim(),
        isPaid: _isPaid,
        compensation: _isPaid && _compensationCtrl.text.trim().isNotEmpty
            ? _compensationCtrl.text.trim()
            : null,
        isRemote: _isRemote,
        location: !_isRemote && _locationCtrl.text.trim().isNotEmpty
            ? _locationCtrl.text.trim()
            : null,
        deadline: _deadline,
        createdAt: DateTime.now(),
      );
      await ref.read(opportunityRepositoryProvider).createOpportunity(opp);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Opportunity posted!')));
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
      appBar: AppBar(title: const Text('Post opportunity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Flutter Developer Intern',
                    prefixIcon: Icon(Icons.work_outline)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Type selector
              Text('Opportunity type',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: OpportunityType.values.map((t) {
                  final labels = {
                    OpportunityType.internship: 'Internship',
                    OpportunityType.partTime: 'Part-time',
                    OpportunityType.project: 'Project',
                    OpportunityType.volunteer: 'Volunteer',
                  };
                  final sel = _type == t;
                  return ChoiceChip(
                    label: Text(labels[t]!),
                    selected: sel,
                    onSelected: (_) => setState(() => _type = t),
                    selectedColor: AppColors.primary.withOpacity(0.12),
                    labelStyle: TextStyle(
                        color:
                            sel ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 13),
                    side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.divider),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                    labelText: 'Role category *',
                    prefixIcon: Icon(Icons.category_outlined)),
                items: Opportunity.roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 6,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText:
                      'Describe the role, responsibilities, and what you\'ll learn...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 80)
                    ? 'At least 80 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duration *',
                  hintText: 'e.g. 3 months, 6 weeks',
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              // Skills
              Text('Required skills',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
              // Compensation
              SwitchListTile(
                value: _isPaid,
                onChanged: (v) => setState(() => _isPaid = v),
                title: const Text('This is a paid opportunity'),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              if (_isPaid) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _compensationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Compensation details',
                      hintText: 'e.g. \$200/month, Stipend negotiable',
                      prefixIcon: Icon(Icons.payments_outlined)),
                ),
                const SizedBox(height: 8),
              ],
              // Remote
              SwitchListTile(
                value: _isRemote,
                onChanged: (v) => setState(() => _isRemote = v),
                title: const Text('Remote friendly'),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              if (!_isRemote) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g. Kigali, Rwanda',
                      prefixIcon: Icon(Icons.location_on_outlined)),
                ),
              ],
              const SizedBox(height: 20),
              // Deadline
              Text('Application deadline',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_outlined,
                          size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _post,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Post opportunity'),
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
