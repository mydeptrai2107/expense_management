import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/utils.dart';
import '../../../view_model/wallet/wallet_view_model.dart';
import '../../../widget/custom_header_3.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletListScreen extends StatefulWidget {
  const WalletListScreen({super.key});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WalletViewModel(),
      child: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              children: [
                CustomHeader_3(
                  title: tr('wallet_list_title'),
                  action: GestureDetector(
                    onTap: () {
                      setState(() {
                        viewModel.isSearching = true;
                      });
                    },
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  isSearching: viewModel.isSearching,
                  onSearchChanged: (query) {
                    setState(() {
                      viewModel.searchQuery = query;
                      viewModel.filterWallets(query);
                    });
                  },
                  onSearchClose: () {
                    setState(() {
                      viewModel.isSearching = false;
                      viewModel.searchQuery = '';
                      viewModel.searchController.clear();
                      viewModel.filterWallets('');
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.wallets.length,
                    itemBuilder: (context, index) {
                      final wallet = viewModel.wallets[index];
                      return Card(
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 2.0),
                          leading: CircleAvatar(
                            backgroundColor: parseColor(wallet.color),
                            child: Icon(
                              parseIcon(wallet.icon),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(wallet.name),
                          subtitle: Text(
                            '${formatAmount(wallet.currentBalance)} đ',
                          ),
                          onTap: () {
                            Navigator.pop(context, wallet);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
