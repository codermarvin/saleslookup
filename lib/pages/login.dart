import 'package:flutter/material.dart';
import 'package:saleslookup/pages/sales.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void initState() {
    _username.text = 'hiemmarvin@gmail.com';
    _password.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Wrap(
            children: <Widget>[
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Sales(
                            username: _username.text, password: _password.text),
                      ),
                    );
                  },
                  child: Text('Login'),
                ),
                width: double.infinity,
              ),
            ],
            alignment: WrapAlignment.center,
            runSpacing: 10,
          ),
        ),
        padding: EdgeInsets.all(40.0),
      ),
    );
  }
}
