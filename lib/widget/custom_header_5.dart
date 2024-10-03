import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomHeader_5 extends StatelessWidget {
  final String title;
  final Widget? filterAction;
  final Widget? searchAction;
  final bool isSearching;
  final Function(String)? onSearchChanged;
  final VoidCallback onSearchClose;

  const CustomHeader_5({
    super.key,
    required this.title,
    this.filterAction,
    this.searchAction,
    this.isSearching = false,
    this.onSearchChanged,
    required this.onSearchClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        color: Colors.green,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (filterAction != null)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: filterAction!,
              ),
            Expanded(
              child: Center(
                child: isSearching
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          onChanged: onSearchChanged,
                          decoration: InputDecoration(
                            hintText: tr('search'),
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : Text(
                        title,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            if (isSearching)
              GestureDetector(
                onTap: onSearchClose,
                child: const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            if (!isSearching && searchAction != null)
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: searchAction!,
              ),
          ],
        ),
      ),
    );
  }
}
