//auth code here...for now placeholder
// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:sit_user/net/flutterfire.dart';
import 'package:sit_user/ui/create-new-account.dart';

import 'home.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pallete.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImage(
          image: 'assets/images/pp.png',
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Flexible(
                child: Center(
                  child: Text(
                    'Express',
                    style: TextStyle(
                        color: Color.fromARGB(255, 27, 196, 247),
                        fontSize: 60,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextInputField(
                    icon: FontAwesomeIcons.envelopeCircleCheck,
                    hint: 'Email',
                    inputType: TextInputType.emailAddress,
                    inputAction: TextInputAction.next,
                    inputController: _emailField,

                  ),
                  PasswordInput(
                    icon: FontAwesomeIcons.lock,
                    hint: 'Password',
                    inputAction: TextInputAction.done,
                    inputController: _passwordField,
                    
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, 'ForgotPassword'),
                    child: Text(
                      'Forgot Password',
                      style: kBodyText,
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                   GestureDetector(
                      onTap: () => {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateNewAccount(),
                        ),
                      )},
                      child: Container(
                        child: Text(
                          'Create Account',
                        style: kBodyText,
                  ),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(width: 1, color: kBlue))),
                ),
              ),
                	
                  SizedBox(
                    height: 22,
                  ),
                ],
              ),
             
              	GestureDetector(
                    onTap:() async {
                    bool shouldNavigate = await signIn(_emailField.text, _passwordField.text);
                    if (shouldNavigate) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeView(),
                        ),
                        );
                      }
                    },
                    child: Container(
                        child: Text(
                        'Login',
                    style: kBodyText,
                    ),
                    decoration: BoxDecoration(
                        border:
                          Border(bottom: BorderSide(width: 1, color: kBlue))),
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        )
      ],
    );
  }
}