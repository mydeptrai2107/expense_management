import 'package:expense_management/widget/wallet_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_management/model/transfer_model.dart';
import 'package:expense_management/widget/custom_header_1.dart';
import 'package:expense_management/widget/custom_snackbar_2.dart';
import '../../utils/utils.dart';
import '../../view_model/transfer/edit_transfer_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import 'package:easy_localization/easy_localization.dart';

class EditTransferScreen extends StatefulWidget {
  final Transfer transfer;

  const EditTransferScreen({super.key, required this.transfer});

  @override
  _EditTransferScreenState createState() => _EditTransferScreenState();
}

class _EditTransferScreenState extends State<EditTransferScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel =
        Provider.of<EditTransferViewModel>(context, listen: false);
    viewModel.initialize(widget.transfer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
           CustomHeader_1(title: tr('edit_transfer_title')),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer<EditTransferViewModel>(
                  builder: (context, viewModel, child) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return WalletSelectionDialog(
                                  wallets: viewModel.wallets,
                                  onSelect: (wallet) {
                                    viewModel.setSelectedFromWallet(wallet);
                                  },
                                );
                              },
                            );
                          },
                          child: InputDecorator(
                            decoration:  InputDecoration(
                              labelText: tr('select_source_wallet_label'),
                            ),
                            child: viewModel.selectedFromWallet != null
                                ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: parseColor(viewModel.selectedFromWallet!.color),
                                  child: Icon(
                                    parseIcon(viewModel.selectedFromWallet!.icon),
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    viewModel.selectedFromWallet!.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                                :  Text(tr('wallet_placeholder')),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return WalletSelectionDialog(
                                  wallets: viewModel.wallets
                                      .where((wallet) =>
                                          wallet !=
                                          viewModel.selectedFromWallet)
                                      .toList(),
                                  onSelect: (wallet) {
                                    viewModel.setSelectedToWallet(wallet);
                                  },
                                );
                              },
                            );
                          },
                          child: InputDecorator(
                            decoration:  InputDecoration(
                              labelText: tr('select_destination_wallet_label'),
                            ),
                            child: viewModel.selectedToWallet != null
                                ? Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: parseColor(viewModel.selectedToWallet!.color),
                                  child: Icon(
                                    parseIcon(viewModel.selectedToWallet!.icon),
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    viewModel.selectedToWallet!.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                                :  Text(tr('wallet_placeholder')),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                controller: viewModel.amountController,
                                decoration:  InputDecoration(
                                    labelText: tr('transfer_amount_label')),
                                style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.right,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => viewModel.updateButtonState,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 20.0),
                                child: Text(
                                  '₫',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: TextFormField(
                                readOnly: true,
                                controller: viewModel.dateController,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    locale: context.locale,
                                    context: context,
                                    initialDate: viewModel.selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null &&
                                      picked != viewModel.selectedDate) {
                                    viewModel.setSelectedDate(picked);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: tr('select_date'),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: TextFormField(
                                readOnly: true,
                                controller: viewModel.hourController,
                                onTap: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: viewModel.selectedHour,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Localizations.override(
                                        context: context,
                                        locale: context.locale,
                                        child: child,
                                      );
                                    },
                                  );
                                  if (picked != null &&
                                      picked != viewModel.selectedHour) {
                                    viewModel.setSelectedHour(picked);
                                  }
                                },
                                decoration:  InputDecoration(
                                  labelText: tr('select_time'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(400),
                          ],
                          controller: viewModel.noteController,
                          decoration:  InputDecoration(labelText: tr('note_label')),
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton_2(
                          onPressed: viewModel.enableButton
                              ? () async {
                                  final updatedTransfer =
                                      await viewModel.updateTransfer(
                                          context, widget.transfer.transferId);
                                  if (updatedTransfer != null) {
                                    await CustomSnackBar_2.show(
                                        context, tr('update_successful'));
                                    Navigator.pop(context, updatedTransfer);
                                  }
                                }
                              : null,
                          text: tr('save_button'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
