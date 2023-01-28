import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class FancySearchField extends StatefulWidget {
  const FancySearchField({
    Key? key,
    required this.loader,
    required this.itemBuilder,
    required this.onSelected,
    this.errorBuilder,
    this.noResultWidget,
    this.hint,
    this.hintStyle,
    this.label,
    this.labelStyle,
    this.margin,
    this.trailing,
    this.paddingHorizontal = 20,
    this.paddingVertical = 0,
  }) : super(key: key);

  final double paddingVertical, paddingHorizontal;

  final String? hint, label;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Function(Object) onSelected;
  final Widget Function(Object) itemBuilder;
  final Widget Function(Object)? errorBuilder;
  final Future<List<dynamic>> Function(String) loader;
  final Widget? noResultWidget;
  final EdgeInsets? margin;
  final Widget? trailing;

  @override
  State<FancySearchField> createState() => _FancySearchFieldState();
}

class _FancySearchFieldState extends State<FancySearchField> {
  TextEditingController controller = TextEditingController();
  List<dynamic> result = [];
  String? error;
  late FocusNode myFocus;

  @override
  void initState() {
    myFocus = FocusNode();
    myFocus.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        autofocus: false,
        focusNode: myFocus,
        style: widget.labelStyle ?? const TextStyle(fontSize: 14),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintStyle: widget.hintStyle ?? const TextStyle(fontSize: 14),
            labelStyle: widget.labelStyle ?? const TextStyle(fontSize: 14),
            hintText: widget.hint),
      ),
      suggestionsCallback: (pattern) async {
        return await widget.loader(pattern);
      },
      itemBuilder: (context, suggestion) {
        return widget.itemBuilder(suggestion ?? const SizedBox());
      },
      noItemsFoundBuilder: ((context) {
        return widget.noResultWidget ??
            const ListTile(
              title: Text('No results found'),
            );
      }),
      onSuggestionSelected: (suggestion) {
        if (suggestion != null) {
          widget.onSelected(suggestion);
        }
      },
    );
  }
}
