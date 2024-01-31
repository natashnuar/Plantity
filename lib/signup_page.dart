import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'main.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  var confirmPassword;

  bool isLoading = false;

  Future _register() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      setState(() {
        isLoading = true;
      });

      // Create a new user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Update the user's profile (including the display name)
      await user?.updateProfile(displayName: name.text);

      // Navigate to the PlantPage after successful registration
      Navigator.pushNamed(context, PlantPageRoute.routeName);

      await FirebaseFirestore.instance.collection('user').doc(user?.uid).set({
        'name': name.text,
        'email': email.text,
      });

      final CollectionReference newCollection = FirebaseFirestore.instance
          .collection('user')
          .doc(user?.uid)
          .collection('savedPlant');

      await newCollection.doc(user?.uid).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Handle any errors that occur during the registration process
      print('Error registering user: $error');

      Utils.showSnackBar(error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.1,
                child: const Center(
                  child: Text(
                    'Plantity',
                    style: TextStyle(
                      color: Colors.lightGreen,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 46,
                child: Center(
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color.fromARGB(123, 0, 61, 2),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
                child: Center(
                  child: Text(
                    'Create a new account',
                    style: TextStyle(
                      color: Color.fromARGB(123, 0, 61, 2),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 70,
                      width: 500,
                      child: Center(
                        child: TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      width: 500,
                      child: Center(
                        child: TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Email',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email) =>
                              email != null && !EmailValidator.validate(email)
                                  ? 'Enter a valid email'
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      width: 500,
                      child: Center(
                        child: TextFormField(
                          controller: password,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Password',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value != null && value.length < 6
                                  ? 'Enter minimum 6 characters'
                                  : null,
                          obscureText: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      width: 500,
                      child: Center(
                        child: TextFormField(
                            controller: confirmPassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.green),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: 'Confirm Password',
                            ),
                            obscureText: true,
                            onChanged: (value) {
                              setState(() {
                                confirmPassword.text = value;
                              });
                            },
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return 'Confirm password is required please enter';
                              }
                              if (value != password.text) {
                                return 'Password does not match';
                              }
                              return null;
                            }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        fixedSize: const Size(200, 50),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              MyHomePageRoute.routeName,
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
