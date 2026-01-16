import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/extensions/theme_extensions_utils.dart';
import '../snackbar/snackbar.dart';
import '../common/app_haptic_feedback.dart';
import 'app_textfield.dart';
import 'field_variants.dart';

class FieldShowcaseScreen extends StatefulWidget {
  const FieldShowcaseScreen({super.key});

  @override
  State<FieldShowcaseScreen> createState() => _FieldShowcaseScreenState();
}

class _FieldShowcaseScreenState extends State<FieldShowcaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  final _multilineController = TextEditingController();

  String _focusStatus = 'No field focused';
  String _validationMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  void _handleFormSubmission() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _validationMessage = 'Form is valid! ✅';
      });
      AppSnackBar.showSuccess(context, message: 'Form submitted successfully!');
    } else {
      setState(() {
        _validationMessage = 'Please fix the errors above ❌';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Field Showcase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicators
              _buildStatusSection(),
              const SizedBox(height: 24),

              // Basic variants
              _buildVariantsSection(),
              const SizedBox(height: 24),

              // Label positioning
              _buildLabelPositioningSection(),
              const SizedBox(height: 24),

              // Sizes demonstration
              _buildSizesSection(),
              const SizedBox(height: 24),

              // Named constructors
              _buildNamedConstructorsSection(),
              const SizedBox(height: 24),

              // Prefix and suffix examples
              _buildPrefixSuffixSection(),
              const SizedBox(height: 24),

              // Validation examples
              _buildValidationSection(),
              const SizedBox(height: 24),

              // States demonstration
              _buildStatesSection(),
              const SizedBox(height: 24),

              // Advanced features
              _buildAdvancedFeaturesSection(),
              const SizedBox(height: 24),

              // Form submission
              _buildFormSubmissionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Focus: $_focusStatus'),
            if (_validationMessage.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Validation: $_validationMessage',
                style: TextStyle(
                  color: _validationMessage.contains('✅')
                      ? context.semanticColors.success
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Field Variants', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AppTextField(
          variant: FieldVariant.outline,
          labelText: 'Outline Variant',
          hintText: 'Enter text here...',
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Outline field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          variant: FieldVariant.filled,
          labelText: 'Filled Variant',
          hintText: 'Enter text here...',
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Filled field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 16),
        // AppTextField(
        //   variant: FieldVariant.underline,
        //   labelText: 'Underline Variant',
        //   hintText: 'Enter text here...',
        //   onFocusChange: (focused) {
        //     setState(() {
        //       _focusStatus =
        //           focused ? 'Underline field focused' : 'No field focused';
        //     });
        //   },
        // ),
      ],
    );
  }

  Widget _buildLabelPositioningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label Positioning',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Above Label (Default)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AppTextField(
          labelText: 'Label Above Field',
          labelPosition: LabelPosition.above,
          hintText: 'This label is positioned above the field with 8px spacing',
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Above label field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Floating Label (In Border)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AppTextField(
          labelText: 'Floating Label',
          labelPosition: LabelPosition.floating,
          hintText: 'This label floats in the border',
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Floating label field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Comparison with Different Variants',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AppTextField(
          variant: FieldVariant.filled,
          labelText: 'Above Label - Filled',
          labelPosition: LabelPosition.above,
          hintText: 'Filled variant with above label',
        ),
        const SizedBox(height: 16),
        AppTextField(
          variant: FieldVariant.filled,
          labelText: 'Floating Label - Filled',
          labelPosition: LabelPosition.floating,
          hintText: 'Filled variant with floating label',
        ),
      ],
    );
  }

  Widget _buildSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Field Sizes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AppTextField(
          size: FieldSize.small,
          labelText: 'Small Size',
          hintText: 'Small field...',
        ),
        const SizedBox(height: 12),
        AppTextField(
          size: FieldSize.medium,
          labelText: 'Medium Size',
          hintText: 'Medium field...',
        ),
        const SizedBox(height: 12),
        AppTextField(
          size: FieldSize.large,
          labelText: 'Large Size',
          hintText: 'Large field...',
        ),
      ],
    );
  }

  Widget _buildNamedConstructorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Named Constructors',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        AppTextField.email(
          controller: _emailController,
          labelText: 'Email Address',
          hintText: 'Enter your email...',
          validator: _validateEmail,
          prefixIcon: const Icon(Icons.email),
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Email field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 16),
        AppTextField.password(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'Enter your password...',
          validator: _validatePassword,
          prefixIcon: const Icon(Icons.lock),
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Password field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 16),
        AppTextField.search(
          controller: _searchController,
          hintText: 'Search for anything...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Search field focused'
                  : 'No field focused';
            });
          },
        ),
        const SizedBox(height: 16),
        AppTextField.multiline(
          controller: _multilineController,
          labelText: 'Comments',
          hintText: 'Enter your comments here...',
          maxLines: 4,
          minLines: 2,
          maxLength: 500,
          onFocusChange: (focused) {
            setState(() {
              _focusStatus = focused
                  ? 'Multiline field focused'
                  : 'No field focused';
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrefixSuffixSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prefix & Suffix Examples',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Price',
          hintText: '0.00',
          keyboardType: TextInputType.number,
          prefixText: '\$',
          suffixText: 'USD',
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Website URL',
          hintText: 'example.com',
          keyboardType: TextInputType.url,
          prefixText: 'https://',
          suffixIcon: const Icon(Icons.link),
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Phone Number',
          hintText: '(555) 123-4567',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone),
          suffixIcon: IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: () {
              AppSnackBar.showInfo(context, message: 'Open contacts');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildValidationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validation Examples',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Required Field',
          hintText: 'This field is required',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Minimum Length (5 chars)',
          hintText: 'Enter at least 5 characters',
          validator: (value) {
            if (value == null || value.length < 5) {
              return 'Must be at least 5 characters';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Numbers Only',
          hintText: 'Enter numbers only',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _buildStatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Field States', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Normal State',
          hintText: 'This is a normal field',
          helperText: 'Helper text provides additional context',
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Error State',
          hintText: 'This field has an error',
          errorText: 'This is an error message',
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Disabled State',
          hintText: 'This field is disabled',
          enabled: false,
          initialValue: 'Cannot edit this text',
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Read Only State',
          hintText: 'This field is read only',
          readOnly: true,
          initialValue: 'Read only text',
          helperText: 'This field cannot be edited but can be focused',
        ),
      ],
    );
  }

  Widget _buildAdvancedFeaturesSection() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Features',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Custom Styling',
          hintText: 'Custom colors and styling',
          fillColor: scheme.primaryContainer.withValues(alpha: 0.2),
          borderColor: scheme.primary,
          textColor: scheme.onPrimaryContainer,
          cursorColor: scheme.primary,
        ),
        const SizedBox(height: 16),
        // Focus animations are handled internally by the design system.
        AppTextField(
          labelText: 'Character Counter',
          hintText: 'Type something...',
          maxLength: 50,
          helperText: 'Maximum 50 characters allowed',
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Custom Haptic Feedback',
          hintText: 'Feel the vibration on interaction',
          hapticFeedback: AppHapticFeedback.mediumImpact,
        ),
        const SizedBox(height: 16),
        AppTextField(
          labelText: 'Semantic Label',
          hintText: 'Accessible field',
          semanticLabel: 'Enter your full name for accessibility',
          helperText: 'This field has enhanced accessibility',
        ),
      ],
    );
  }

  Widget _buildFormSubmissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Form Submission', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _handleFormSubmission,
                child: const Text('Validate Form'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _formKey.currentState?.reset();
                  _emailController.clear();
                  _passwordController.clear();
                  _searchController.clear();
                  _multilineController.clear();
                  setState(() {
                    _validationMessage = '';
                    _focusStatus = 'No field focused';
                  });
                },
                child: const Text('Reset Form'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Tips:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        const Text(
          '• Try different field variants and sizes\n'
          '• Test validation by entering invalid data\n'
          '• Experience haptic feedback on supported devices\n'
          '• Notice focus animations and state changes\n'
          '• Test accessibility features with screen readers',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
