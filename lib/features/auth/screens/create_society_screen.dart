import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../provider/auth_provider.dart';

class CreateSocietyScreen extends StatefulWidget {
  const CreateSocietyScreen({super.key});

  @override
  State<CreateSocietyScreen> createState() => _CreateSocietyScreenState();
}

class _CreateSocietyScreenState extends State<CreateSocietyScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _totalFlatsController = TextEditingController();
  final _flatController = TextEditingController();
  final _wingController = TextEditingController();
  final _floorController = TextEditingController();
  bool _saving = false;
  int _step = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _totalFlatsController.dispose();
    _flatController.dispose();
    _wingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  bool get _canProceedStep0 =>
      _nameController.text.trim().isNotEmpty &&
      _codeController.text.trim().isNotEmpty;

  bool get _canProceedStep1 =>
      _addressController.text.trim().isNotEmpty &&
      _cityController.text.trim().isNotEmpty &&
      _stateController.text.trim().isNotEmpty &&
      _pincodeController.text.trim().isNotEmpty &&
      _totalFlatsController.text.trim().isNotEmpty;

  bool get _canSubmit => _flatController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().createSociety(
            name: _nameController.text.trim(),
            code: _codeController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            pincode: _pincodeController.text.trim(),
            totalFlats: int.tryParse(_totalFlatsController.text.trim()) ?? 0,
            flatNumber: _flatController.text.trim(),
            wing: _wingController.text.trim().isEmpty
                ? null
                : _wingController.text.trim(),
            floor: int.tryParse(_floorController.text.trim()),
          );
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StepIndicator(current: _step, total: 3),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_step == 0) ..._buildStep0(),
              if (_step == 1) ..._buildStep1(),
              if (_step == 2) ..._buildStep2(),
              const Spacer(),
              FilledButton(
                onPressed: _step == 0
                    ? (_canProceedStep0
                        ? () => setState(() => _step = 1)
                        : null)
                    : _step == 1
                        ? (_canProceedStep1
                            ? () => setState(() => _step = 2)
                            : null)
                        : (_canSubmit && !_saving ? _submit : null),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        _step < 2 ? 'Continue' : 'Create Society',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep0() {
    return [
      const Text(
        'Society details',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.gray900,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Enter the name and a unique code for your society.',
        style: TextStyle(color: AppColors.gray500, fontSize: 15, height: 1.4),
      ),
      const SizedBox(height: 28),
      _buildField(_nameController, 'Society name', onChanged: (_) => setState(() {})),
      const SizedBox(height: 14),
      _buildField(
        _codeController,
        'Society code',
        hint: 'e.g. GREENVALLEY',
        capitalization: TextCapitalization.characters,
        onChanged: (_) => setState(() {}),
      ),
    ];
  }

  List<Widget> _buildStep1() {
    return [
      const Text(
        'Address',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.gray900,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Where is your society located?',
        style: TextStyle(color: AppColors.gray500, fontSize: 15, height: 1.4),
      ),
      const SizedBox(height: 28),
      _buildField(_addressController, 'Street address', onChanged: (_) => setState(() {})),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _buildField(_cityController, 'City', onChanged: (_) => setState(() {})),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildField(_stateController, 'State', onChanged: (_) => setState(() {})),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _buildField(
              _pincodeController,
              'Pincode',
              keyboard: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildField(
              _totalFlatsController,
              'Total flats',
              keyboard: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      const Text(
        'Your flat',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.gray900,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Enter your flat details. You will be the admin of this society.',
        style: TextStyle(color: AppColors.gray500, fontSize: 15, height: 1.4),
      ),
      const SizedBox(height: 28),
      _buildField(_flatController, 'Flat number', onChanged: (_) => setState(() {})),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(child: _buildField(_wingController, 'Wing (optional)')),
          const SizedBox(width: 12),
          Expanded(
            child: _buildField(
              _floorController,
              'Floor (optional)',
              keyboard: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'You will be the admin and can approve new members joining your society.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryDark,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      textCapitalization: capitalization,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
