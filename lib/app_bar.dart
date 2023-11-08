import 'package:flutter/material.dart';

AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: Colors.lightBlue, // Set your desired background color
    title: Text(
      'All Tasks',
      style: TextStyle(
        color: Colors
            .white, // Choose a color that contrasts well with the background
        fontWeight: FontWeight.bold, // If your design requires bold text
      ),
    ),
    centerTitle: true, // If your title should be centered
    elevation: 0, // Removes the shadow underneath the AppBar
    actions: [
      // If you have any actions, add them here
    ],
  );
}
