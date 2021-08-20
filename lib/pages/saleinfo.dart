import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';

class SaleDetail {
  String product;
  String quantity;
  String price;
  String subtotal;
}

class SaleInfo extends StatefulWidget {
  final int saleId;
  final String username;
  final String password;

  const SaleInfo({Key key, this.saleId, this.username, this.password})
      : super(key: key);

  @override
  _SaleInfoState createState() => _SaleInfoState();
}

class _SaleInfoState extends State<SaleInfo> {
  TextEditingController _ctrlId = TextEditingController();
  TextEditingController _ctrlName = TextEditingController();
  TextEditingController _ctrlDate = TextEditingController();
  TextEditingController _ctrlNoTax = TextEditingController();
  TextEditingController _ctrlTax = TextEditingController();
  TextEditingController _ctrlTotal = TextEditingController();

  final client = OdooClient('https://codermarvin.odoo.com');
  final database = 'codermarvin';

  List _saleList = [];

  void _getSaleHeader(int saleId) async {
    AuthenticateCallback auth =
        await client.authenticate(widget.username, widget.password, database);
    if (auth.isSuccess) {
      final user = auth.getUser();
      print('Hey, ${user.name}');
    } else {
      Navigator.pop(context);
      print('Login failed');
    }

    OdooResponse result = await client.searchRead(
      'sale.order',
      [
        ['id', '=', saleId]
      ],
      [
        'id',
        'display_name',
        'date_order',
        'amount_untaxed',
        'amount_tax',
        'amount_total',
      ],
    );
    if (!result.hasError()) {
      print('Successful');
      var response = result.getResult();
      var data = json.encode(response['records']);
      var decoded = json.decode(data);
      print(decoded);
      _ctrlId.text = decoded[0]['id'].toString();
      _ctrlName.text = decoded[0]['display_name'];
      _ctrlDate.text = decoded[0]['date_order'];
      _ctrlNoTax.text = decoded[0]['amount_untaxed'].toString();
      _ctrlTax.text = decoded[0]['amount_tax'].toString();
      _ctrlTotal.text = decoded[0]['amount_total'].toString();
      setState(() {});
    } else {
      print(result.getError());
    }
  }

  void _getSaleDetail(int saleId) async {
    AuthenticateCallback auth =
        await client.authenticate(widget.username, widget.password, database);
    if (auth.isSuccess) {
      final user = auth.getUser();
      print('Hey, ${user.name}');
    } else {
      Navigator.pop(context);
      print('Login failed');
    }

    OdooResponse result = await client.searchRead(
      'sale.order.line',
      [
        ['order_id', '=', saleId]
      ],
      [
        'id',
        'product_uom_qty',
        'price_unit',
        'price_subtotal',
        'product_id',
      ],
    );
    if (!result.hasError()) {
      print('Successful');
      var response = result.getResult();
      var data = json.encode(response['records']);
      var decoded = json.decode(data);
      print(decoded);
      _saleList.clear();
      decoded.forEach((sale) async {
        var saleDetail = SaleDetail();
        saleDetail.product = sale['product_id'][1];
        saleDetail.quantity = sale['product_uom_qty'].toString();
        saleDetail.price = sale['price_unit'].toString();
        saleDetail.subtotal = sale['price_subtotal'].toString();
        _saleList.add(saleDetail);
      });
      print(_saleList);
      setState(() {});
    } else {
      print(result.getError());
    }
  }

  @override
  void initState() {
    super.initState();
    _getSaleHeader(widget.saleId);
    _getSaleDetail(widget.saleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale Details'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ctrlId,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            TextField(
              controller: _ctrlName,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Number',
              ),
            ),
            TextField(
              controller: _ctrlDate,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Order Date',
              ),
            ),
            TextField(
              controller: _ctrlNoTax,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Untaxed Amount',
              ),
            ),
            TextField(
              controller: _ctrlTax,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Taxes',
              ),
            ),
            TextField(
              controller: _ctrlTotal,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Total',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'PRODUCT',
                  ),
                  Text(
                    'QUANTITY',
                  ),
                  Text(
                    'UNIT PRICE',
                  ),
                  Text(
                    'SUB-TOTAL',
                  ),
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: ListView.separated(
                  itemCount: _saleList.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _saleList[index].product,
                        ),
                        Text(
                          _saleList[index].quantity,
                        ),
                        Text(
                          _saleList[index].price,
                        ),
                        Text(
                          _saleList[index].subtotal,
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
