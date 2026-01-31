import 'package:flutter/material.dart';

class InvitationAddPage extends StatefulWidget {
  const InvitationAddPage({super.key});

  @override
  State<InvitationAddPage> createState() => _InvitationAddPageState();
}

class _InvitationAddPageState extends State<InvitationAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateFromController = TextEditingController();
  final _dateToController = TextEditingController();

  String? _entity;
  String? _site;
  String? _department;
  String? _personToVisit;
  String? _visitorType;

  @override
  void dispose() {
    _companyController.dispose();
    _purposeController.dispose();
    _emailController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required TextEditingController controller,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      controller.text = '${picked.year}-${_two(picked.month)}-${_two(picked.day)}';
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void _clearForm() {
    _formKey.currentState?.reset();
    _companyController.clear();
    _purposeController.clear();
    _emailController.clear();
    _dateFromController.clear();
    _dateToController.clear();
    setState(() {
      _entity = null;
      _site = null;
      _department = null;
      _personToVisit = null;
      _visitorType = null;
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation submitted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitation Add'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Text(
                'All fields with an asterisk (*) are mandatory.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _ReadOnlyField(
                label: 'User Name',
                value: 'Ryan',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _entity,
                decoration: const InputDecoration(labelText: 'Entity *'),
                items: const [
                  DropdownMenuItem(
                    value: 'AGYTEK - Agytek1231',
                    child: Text('AGYTEK - Agytek1231'),
                  ),
                ],
                onChanged: (value) => setState(() => _entity = value),
                validator: (value) =>
                    value == null ? 'Entity is required.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _site,
                decoration: const InputDecoration(labelText: 'Site *'),
                items: const [
                  DropdownMenuItem(
                    value: 'FACTORY1 - FACTORY1 T',
                    child: Text('FACTORY1 - FACTORY1 T'),
                  ),
                ],
                onChanged: (value) => setState(() => _site = value),
                validator: (value) =>
                    value == null ? 'Site is required.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(labelText: 'Department *'),
                items: const [
                  DropdownMenuItem(
                    value: 'Administration',
                    child: Text('Administration'),
                  ),
                  DropdownMenuItem(
                    value: 'Operations',
                    child: Text('Operations'),
                  ),
                ],
                onChanged: (value) => setState(() => _department = value),
                validator: (value) =>
                    value == null ? 'Department is required.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _personToVisit,
                decoration: const InputDecoration(labelText: 'Person to Visit *'),
                items: const [
                  DropdownMenuItem(
                    value: 'Ryan',
                    child: Text('Ryan'),
                  ),
                  DropdownMenuItem(
                    value: 'Aisha',
                    child: Text('Aisha'),
                  ),
                ],
                onChanged: (value) => setState(() => _personToVisit = value),
                validator: (value) =>
                    value == null ? 'Person to visit is required.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _visitorType,
                decoration: const InputDecoration(labelText: 'Visitor Type *'),
                items: const [
                  DropdownMenuItem(
                    value: 'Visitor',
                    child: Text('Visitor'),
                  ),
                  DropdownMenuItem(
                    value: 'Contractor',
                    child: Text('Contractor'),
                  ),
                ],
                onChanged: (value) => setState(() => _visitorType = value),
                validator: (value) =>
                    value == null ? 'Visitor type is required.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company/Visitor Name *',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Company/visitor name is required.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purposeController,
                decoration:
                    const InputDecoration(labelText: 'Invitation Purpose *'),
                minLines: 3,
                maxLines: 5,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Invitation purpose is required.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Send Invitation To (Email) *'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Email is required.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateFromController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Visit Date From *',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(controller: _dateFromController),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Visit date from is required.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateToController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Visit Date To *',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(controller: _dateToController),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Visit date to is required.'
                        : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Send Invite'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _clearForm,
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value),
    );
  }
}
