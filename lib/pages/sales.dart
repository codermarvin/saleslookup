import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import 'package:saleslookup/pages/saleinfo.dart';

class Sales extends StatefulWidget {
  final String username;
  final String password;

  const Sales({Key key, this.username, this.password}) : super(key: key);

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  final client = OdooClient('https://codermarvin.odoo.com');
  final database = 'codermarvin';

  Future<dynamic> _getSales() async {
    final domain = [];
    var fields = ['id', 'display_name', 'amount_total'];
    AuthenticateCallback auth =
        await client.authenticate(widget.username, widget.password, database);
    if (auth.isSuccess) {
      final user = auth.getUser();
      print('Hey, ${user.name}');
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid username and password')));
      print('Login failed');
    }

    OdooResponse result = await client.searchRead('sale.order', domain, fields);
    if (!result.hasError()) {
      print('Successful');
      var response = result.getResult();
      var data = json.encode(response['records']);
      var decoded = json.decode(data);
      print(decoded);
      return decoded;
    } else {
      print(result.getError());
    }
  }

  Widget buildListItem(Map<String, dynamic> record) {
    return ListTile(
      title: Text(record['display_name']),
      subtitle: Text(record['amount_total'].toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
      ),
      body: Center(
        child: FutureBuilder(
          future: _getSales(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final record = snapshot.data[index] as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleInfo(
                            saleId: record['id'],
                            username: widget.username,
                            password: widget.password,
                          ),
                        ),
                      ).whenComplete(() => _getSales());
                    },
                    child: buildListItem(record),
                  );
                },
              );
            } else {
              if (snapshot.hasError) return Text('Unable to fetch data');
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
