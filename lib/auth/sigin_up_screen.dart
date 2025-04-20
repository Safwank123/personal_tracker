import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_tracker/auth/auth_service.dart';
import 'package:personal_tracker/utiles/validators.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await Provider.of<AuthService>(context, listen: false).signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        context.go('/dashboard');
      } catch (error) {
        debugPrint('Sign up error: $error');
        setState(() {
          _errorMessage = error.toString().contains('Supabase')
              ? 'Email already in use or invalid credentials'
              : 'Failed to sign up. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D2A3A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
            
             
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/login_logo.png',
                        height: 80,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
            
                const SizedBox(height: 40),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
            
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField("Email Address", _emailController, TextInputType.emailAddress, false, Validators.email),
                      const SizedBox(height: 16),
                      _buildTextField("Password", _passwordController, TextInputType.visiblePassword, true, Validators.required),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Confirm Password",
                        _confirmPasswordController,
                        TextInputType.visiblePassword,
                        true,
                        (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 20),
            
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCD95B),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _isLoading ? null : _signUp,
                    child: Text(_isLoading ? 'Signing up...' : 'Sign Up',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            
                const SizedBox(height: 20),
            
               
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Log In",
                            style: TextStyle(color: Color(0xFFFCD95B), fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
    bool obscure,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF3A4B5C),
            prefixIcon: Icon(
              obscure ? Icons.lock : Icons.email,
              color: Colors.white,
            ),
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
