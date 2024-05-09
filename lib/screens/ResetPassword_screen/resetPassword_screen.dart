import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learning_platform/constants.dart';
import 'package:learning_platform/screens/home_screen/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  static String routeName = 'ResetPasswordScreen';

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String oldPassword;
  late String newPassword;
  late String confirmNewPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kOtherColor,
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 60, left: 40, right: 40),
        color: kOtherColor,
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: SvgPicture.asset(
                            'assets/icons/change-password-icon.svg',
                            height: 40.0,
                            width: 40.0,
                            color: kPrimaryColor,
                          ),
                        ),
                        sizedBox,
                        const Text(
                          "Reset Password?",
                          style: TextStyle(
                            fontSize: 36,
                            color: kTextBlackColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        sizedBox,
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.visiblePassword,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: kTextBlackColor),
                          decoration: const InputDecoration(
                            labelText: "Enter Old Password",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            isDense: true,
                          ),
                          onChanged: (value) => oldPassword = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Some Text';
                            }
                            return null;
                          },
                        ),
                        kHalfSizedBox,
                        TextFormField(
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.visiblePassword,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: kTextBlackColor),
                          decoration: const InputDecoration(
                            labelText: "Enter New Password",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            isDense: true,
                          ),
                          onChanged: (value) => newPassword = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Some Text';
                            }
                            else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        kHalfSizedBox,
                        TextFormField(
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.visiblePassword,
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: kTextBlackColor),
                          decoration: const InputDecoration(
                            labelText: "Confirm New Password",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            isDense: true,
                          ),
                          onChanged: (value) => confirmNewPassword = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Some Text';
                            }
                            else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            else if (value != newPassword) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        kHalfSizedBox,
                        Container(
                          height: 60,
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.3, 1],
                              colors: [
                                kSecondaryColor,
                                kPrimaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: SizedBox.expand(
                            child: TextButton(
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kTextWhiteColor,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (newPassword == confirmNewPassword) {
                                     _updatePassword(context, oldPassword, newPassword, confirmNewPassword);
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        sizedBox,
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

void _updatePassword(BuildContext context, String oldPassword, String newPassword, String confirmPassword) async {
  try {
    final response = await http.post(
      Uri.parse('${baseURL}change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessVerificationToken', 
      },
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword
      }),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Password Changed"),
            content: const Text("Your Password has been changed successfully."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
    else {
      _showErrorSnackBar(context, 'Password do not match');
    }
  }
  catch (e) {
    _showErrorSnackBar(context, 'No Internet Connection');
  }
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}