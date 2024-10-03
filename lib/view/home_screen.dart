import 'dart:io';
import 'package:expense_management/view_model/user/edit_profile_view_model.dart';
import 'package:expense_management/view_model/wallet/wallet_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceVisible = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final walletViewModel =
        Provider.of<WalletViewModel>(context, listen: false);
    final profileViewModel =
        Provider.of<EditProfileViewModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      walletViewModel.loadWallets(),
      profileViewModel.loadProfile(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          strokeWidth: 6.0,)
        )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          _buildUtilities(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        User? user = FirebaseAuth.instance.currentUser;
        String displayName = viewModel.displayName ??
            (user != null ? user.email!.split('@')[0] : tr('user'));

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 5),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: viewModel.imageFile != null
                          ? FileImage(File(viewModel.imageFile!.path))
                          : (viewModel.networkImageUrl != null
                                  ? NetworkImage(viewModel.networkImageUrl!)
                                  : const AssetImage('assets/images/profile.png'))
                              as ImageProvider<Object>,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        '${getGreeting()},\n$displayName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBalance(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalance() {
    return Consumer<WalletViewModel>(
      builder: (context, viewModel, child) {
        String balance = _isBalanceVisible
            ? '${viewModel.formattedTotalBalance} ₫'
            : '***** ₫';
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(7, 5),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('total_balance'),
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        balance,
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                      icon: Icon(
                        _isBalanceVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUtilities() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildUtilityCard(
            icon: FontAwesomeIcons.fileInvoiceDollar,
            color: Colors.grey.shade700,
            title: tr('utility_bill'),
            onTap: () {
              Navigator.pushNamed(context, '/bill-list');
            },
          ),
          _buildUtilityCard(
            icon: Icons.category,
            color: Colors.green,
            title: tr('utility_category'),
            onTap: () {
              Navigator.pushNamed(context, '/category-list');
            },
          ),
          _buildUtilityCard(
            icon: Icons.wallet,
            color: Colors.amberAccent,
            title: tr('utility_wallet'),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => WalletScreen())).then((_) {
              //   final walletViewModel = Provider.of<WalletViewModel>(context, listen: false);
              //   walletViewModel.loadWallets();
              // });
              Navigator.pushNamed(context, '/wallets');
            },
          ),
          _buildUtilityCard(
            icon: Icons.account_balance_wallet,
            color: Colors.red,
            title: tr('utility_budget'),
            onTap: () {
              Navigator.pushNamed(context, '/budget-list');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard(
      {required IconData icon,
      required Color color,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: color),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
