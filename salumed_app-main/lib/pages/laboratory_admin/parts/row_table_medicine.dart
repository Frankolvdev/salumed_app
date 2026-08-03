import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RowTableMedicine extends StatefulWidget {
  Function callbackDelete;
  Map<String, dynamic> values;
  num costDefault;
  num quantityDefault;
  String medicineDefault;
  num amount;
  bool readonly = false;

  Function callbackChange;

  RowTableMedicine(
      this.callbackDelete,
      this.costDefault,
      this.quantityDefault,
      this.medicineDefault,
      this.amount,
      this.callbackChange,
      this.values,
      this.readonly,
      {Key? key})
      : super(key: key);

  @override
  State<RowTableMedicine> createState() => _RowTableMedicineState();
}

class _RowTableMedicineState extends State<RowTableMedicine> {
  final cCost = TextEditingController();
  final cQuantity = TextEditingController();
  final cAmount = TextEditingController();
  final cMedicine = TextEditingController();

  num getAmount() {
    return amount;
  }

  @override
  void initState() {
    super.initState();

    cCost.text = widget.costDefault.toString();
    cQuantity.text = widget.quantityDefault.toString();
    cMedicine.text = widget.medicineDefault;

    cCost.addListener(calAmount);
    cQuantity.addListener(calAmount);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      calAmount();
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    cCost.dispose();
    cQuantity.dispose();
    cAmount.dispose();
    cMedicine.dispose();

    super.dispose();
  }

  num amount = 0;

  calAmount() {
    num cost = 0;
    num quantity = 0;

    if (cCost.text != "" && cQuantity.text != "") {
      cost = double.parse(cCost.text);
      quantity = double.parse(cQuantity.text);
    }

    setState(() {
      amount = cost * quantity;
      cAmount.text = amount.toString();
      widget.amount = amount;
      widget.values = {
        "medicine": cMedicine.text ?? "",
        "cost": cost,
        "amount": amount,
        "quantity": quantity
      };
    });
    widget.callbackChange();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration = InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 171, 171, 171),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 97, 97, 97),
          width: 0.5,
        ),
      ),
    );

    final medicineField = TextFormField(
      textInputAction: TextInputAction.next,
      readOnly: widget.readonly,
      controller: cMedicine,
      keyboardType: TextInputType.name,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: decoration,
      onFieldSubmitted: (val) {},
    );

    final costField = TextFormField(
      textInputAction: TextInputAction.next,
      readOnly: widget.readonly,

      controller: cCost,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: decoration,
      onFieldSubmitted: (val) {},
    );

    final quantityField = TextFormField(
      textInputAction: TextInputAction.next,
      readOnly: widget.readonly,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cQuantity,
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: decoration,
      onFieldSubmitted: (val) {},
    );

    final amountField = TextFormField(
      textInputAction: TextInputAction.next,

      readOnly: true,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cAmount,
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: decoration,
      onFieldSubmitted: (val) {},
    );
    return Container(
      child: Column(
        children: [
          (widget.readonly)
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(flex: 5, child: medicineField),
                    Flexible(flex: 2, child: costField),
                    Flexible(flex: 2, child: quantityField),
                    Flexible(flex: 2, child: amountField)
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                        flex: 0,
                        child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 171, 171, 171),
                                width:
                                    0.5, //                   <--- border width here
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                widget.callbackDelete();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 13.5, horizontal: 11.0),
                                child: FaIcon(FontAwesomeIcons.times,
                                  color: Colors.red,
                                  size: 25,
                                ),
                              ),
                            ))),
                    Flexible(flex: 5, child: medicineField),
                    Flexible(flex: 2, child: costField),
                    Flexible(flex: 2, child: quantityField),
                    Flexible(flex: 2, child: amountField)
                  ],
                )
        ],
      ),
    );
  }
}

