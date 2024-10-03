import 'package:expense_management/view_model/wallet/wallet_view_model.dart';
import 'package:flutter/material.dart';
import 'package:expense_management/model/wallet_model.dart';
import 'package:provider/provider.dart';
import '../utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletSelectionDialog extends StatefulWidget {
  final List<Wallet> wallets;
  final Function(Wallet) onSelect;

  const WalletSelectionDialog({super.key, required this.wallets, required this.onSelect});

  @override
  _WalletSelectionDialogState createState() => _WalletSelectionDialogState();
}

class _WalletSelectionDialogState extends State<WalletSelectionDialog> {
  TextEditingController _searchController = TextEditingController();
  List<Wallet> _filteredWallets = [];

  @override
  void initState() {
    super.initState();
    _filteredWallets = widget.wallets;
    _searchController.addListener(_filterWallets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWallets() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredWallets = widget.wallets.where((wallet) {
        return wallet.name.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletViewModel(),
      child: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          return Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      tr('select_wallet'),
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: tr('search_wallet'),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredWallets.length,
                      itemBuilder: (context, index) {
                        final wallet = _filteredWallets[index];
                        return Card(
                          color: Colors.grey.shade200,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: parseColor(wallet.color),
                              child: Icon(
                                parseIcon(wallet.icon),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(wallet.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              '${formatAmount(wallet.currentBalance)} ₫',
                            ),
                            onTap: () {
                              widget.onSelect(wallet);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            tr('cancel'),
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}