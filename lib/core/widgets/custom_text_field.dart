import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.textEditingController});
  final TextEditingController textEditingController;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        border: buildBorder(),
        enabledBorder: buildBorder(),
        focusedBorder: buildBorder(),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        hintText: "Search",
        hintStyle: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    );
  }
}
