import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/messenger_provider.dart';
import '../../../core/providers/providers.dart';
import '../../auth/presentation/auth_provider.dart';

class SubdomainSettingsScreen extends ConsumerStatefulWidget {
  const SubdomainSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubdomainSettingsScreen> createState() => _SubdomainSettingsScreenState();
}

class _SubdomainSettingsScreenState extends ConsumerState<SubdomainSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slugController = TextEditingController();
  bool _isLoading = false;
  bool _isChecking = false;
  bool _slugAvailable = false;
  String? _currentSlug;

  @override
  void initState() {
    super.initState();
    _loadCurrentSlug();
  }

  Future<void> _loadCurrentSlug() async {
    final user = ref.read(authNotifierProvider).user;
    if (user?.slug != null) {
      setState(() {
        _currentSlug = user!.slug;
        _slugController.text = user.slug!;
      });
    }
  }

  Future<void> _checkSlugAvailability(String slug) async {
    if (slug.isEmpty || slug == _currentSlug) {
      setState(() {
        _slugAvailable = false;
        _isChecking = false;
      });
      return;
    }

    setState(() => _isChecking = true);

    try {
      final service = ref.read(websiteServiceProvider);
      final response = await service.checkSlugAvailability(slug);
      
      setState(() {
        _slugAvailable = response['available'] == true;
        _isChecking = false;
      });

      if (!_slugAvailable && response['reason'] != null) {
        ref.showSnackBar(response['reason'], isError: true);
      }
    } catch (e) {
      setState(() => _isChecking = false);
      ref.showSnackBar('Failed to check slug availability', isError: true);
    }
  }

  Future<void> _saveSlug() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_slugAvailable && _slugController.text != _currentSlug) {
      ref.showSnackBar('Please choose an available slug', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(websiteServiceProvider);
      await service.updateSlug(_slugController.text.trim().toLowerCase());
      
      // Reload user data from server
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final authRepo = ref.read(authRepositoryProvider);
      final updatedUser = await authRepo.getCurrentUser();
      if (updatedUser != null) {
        authNotifier.state = authNotifier.state.copyWith(user: updatedUser);
      }

      ref.showSnackBar('Subdomain updated successfully!', isError: false);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ref.showSnackBar('Failed to update subdomain: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateSlug(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a subdomain';
    }

    final slugRegex = RegExp(r'^[a-z0-9-]+$');
    if (!slugRegex.hasMatch(value)) {
      return 'Only lowercase letters, numbers, and hyphens allowed';
    }

    if (value.length < 3) {
      return 'Subdomain must be at least 3 characters';
    }

    if (value.length > 30) {
      return 'Subdomain must be less than 30 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Website Subdomain'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Your Website URL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose a unique subdomain for your restaurant website. '
                      'Customers will access your menu and place orders at this URL.',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Current URL Display
              if (_currentSlug != null) ...[
                Text(
                  'Current Website URL',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.link, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'https://$_currentSlug.cosmosadmin.com',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Slug Input
              Text(
                'Subdomain',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _slugController,
                      decoration: InputDecoration(
                        hintText: 'my-restaurant',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: _isChecking
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _slugAvailable
                                ? Icon(Icons.check_circle, color: Colors.green.shade600)
                                : null,
                      ),
                      validator: _validateSlug,
                      onChanged: (value) {
                        // Debounce check
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_slugController.text == value) {
                            _checkSlugAvailability(value.trim().toLowerCase());
                          }
                        });
                      },
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      '.cosmosadmin.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Preview URL
              if (_slugController.text.isNotEmpty)
                Text(
                  'Your website will be: https://${_slugController.text.trim().toLowerCase()}.cosmosadmin.com',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSlug,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Subdomain',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slugController.dispose();
    super.dispose();
  }
}
