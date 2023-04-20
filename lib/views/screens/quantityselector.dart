import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final Function(int) onValueChanged;

  const QuantitySelector(
      {super.key, required this.initialValue, required this.onValueChanged});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _incrementValue() {
    setState(() {
      _value++;
      widget.onValueChanged(_value);
    });
  }

  void _decrementValue() {
    setState(() {
      if (_value > 1) {
        _value--;
        widget.onValueChanged(_value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _decrementValue,
          ),
        ),
        Container(
          width: 33,
          child: Center(child: Text('$_value')),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _incrementValue,
          ),
        ),
      ],
    );
  }
}
