import 'package:flutter/material.dart';
import 'package:milma_group/const.dart';
import 'package:milma_group/provider/commonviewmodel.dart';
import 'package:milma_group/screens/event_list.dart';
import 'package:milma_group/session/shared_preferences.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  CommonViewModel? vm;
  bool load = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<CommonViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Image.asset("assets/images/logo.png", height: 150, width: 150),
                const SizedBox(height: 150),

                const Text(
                  "SIGN IN TO CONTINUE",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "ENTER YOUR EMAIL",

                    hintStyle: TextStyle(
                      letterSpacing: 0,
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: Icon(Icons.email, color: Colors.grey.shade500),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _passwordController,
                  cursorColor: Colors.black,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "PASSWORD",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      letterSpacing: 0,
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    prefixIcon: Icon(Icons.lock, color: Colors.grey.shade500),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: load
                      ? Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final connected = await checkInternetConnection();

                              if (connected == false) {
                                snack(
                                  "Please check your connectivity",
                                  context,
                                );

                                return;
                              }
                              setState(() => load = true);

                              vm!
                                  .login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  )
                                  .then((value) {
                                    setState(() => load = false);

                                    if (value['status'] == true) {
                                      Store.setEmail(
                                        _emailController.text.trim(),
                                      );
                                      Store.setLoggedIn("yes");
                                      Store.setToken(
                                        vm!.responsedata?.accessToken ?? "",
                                      );

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EventListScreen(),
                                        ),
                                      );
                                    } else {
                                      snack(
                                        value['message'] ??
                                            'Something went wrong',
                                        context,
                                      );
                                    }
                                  })
                                  .catchError((error) {
                                    setState(() => load = false);
                                    snack(
                                      "Something went wrong. Try again!",
                                      context,
                                    );
                                  });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: primaryColor,
                          ),
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
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
}
