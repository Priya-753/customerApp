import 'dart:typed_data';
import 'package:flutter_customer_app/nas/model_view/google_drive_model_view.dart';
import 'package:provider/provider.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_customer_app/nas/view/screens/base_screen.dart';

class CreditDiscountScreen extends BasePageScreen {
  const CreditDiscountScreen({Key? key}) : super(key: key);

  static const String id = 'credit_discount_screen';

  @override
  _CreditDiscountScreenState createState() => _CreditDiscountScreenState();
}

class _CreditDiscountScreenState extends BasePageScreenState<CreditDiscountScreen> with BaseScreen {
  Uint8List _creditDiscountStructureBytes = Uint8List(100);

  @override
  void initState() {
    fetchCreditDiscountStructureFile();
    super.initState();
    setState(() {
      screenName = "Credit Discount";
      selectedIndex = 2;
    });
  }

  void fetchCreditDiscountStructureFile() async {
    await Provider.of<DriveModelView>(context, listen: false)
        .fetchCreditDiscountStructure();

    Uint8List creditDiscountStructureBytes = Provider.of<DriveModelView>(context, listen: false)
        .creditDiscountStructureBytes;

    setState(() {
      _creditDiscountStructureBytes = creditDiscountStructureBytes;
    });
  }

  @override
  Widget body() {
    return SfPdfViewer.memory(_creditDiscountStructureBytes);
  }
}