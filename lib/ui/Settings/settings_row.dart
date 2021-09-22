import 'package:flutter/material.dart';

class SettingsRow extends StatefulWidget {
  final Function(String label) onIncrease;
  final Function(String label) onDecrease;
  final double _value;
  final String _label;

  const SettingsRow(this._label, this._value, this.onIncrease, this.onDecrease,
      {Key? key})
      : super(key: key);

  @override
  _SettingsRowState createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Text(widget._label),
          new IconButton(
            onPressed: () {
              widget.onIncrease(widget._label);
            },
            icon: new Icon(
              Icons.add_box,
              color: Colors.black,
            ),
          ),
          new Text(widget._value.toStringAsPrecision(2)),
          new IconButton(
            onPressed: () {
              widget.onDecrease(widget._label);
            },
            icon: new Icon(
              Icons.indeterminate_check_box,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
