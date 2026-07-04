import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();
  final confirmPasswordController = TextEditingController();
  Future<void> signup() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty ||
    password.isEmpty ||
    confirmPasswordController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please fill all fields"),
    ),
  );
  return;
}
    if (password != confirmPasswordController.text.trim()) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Passwords do not match"),
    ),
  );
  return;
}

    String? result = await authService.signup(email, password);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully"),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

Row(
  children: const [
    Icon(
      Icons.account_balance_wallet,
      color: Colors.green,
      size: 32,
    ),
    SizedBox(width: 10),
    Text(
      "Pocket Tracker",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

const SizedBox(height: 30),

const Text(
  "Create Account",
  style: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),

const Text(
  "Start tracking your expenses today.",
  style: TextStyle(
    color: Colors.grey,
  ),
),

const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

TextField(
  controller: confirmPasswordController,
  obscureText: true,
  decoration: InputDecoration(
    labelText: "Confirm Password",
    prefixIcon: const Icon(Icons.lock_outline),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  ),
),

const SizedBox(height: 20),

Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Already have an account? "),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Login"),
      ),
    ],
  ),
),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: const Text(
  "Create Account",
  style: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
              ),
            ),
          ],
        ),
      ),
    );
  }
}