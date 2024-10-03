import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../model/bill_model.dart';
import '../../model/enum.dart';
import '../../utils/utils.dart';
import '../../view_model/bill/edit_bill_view_model.dart';
import '../../widget/custom_ElevatedButton_2.dart';
import '../../widget/custom_header_1.dart';
import '../../widget/custom_snackbar_2.dart';
import 'package:easy_localization/easy_localization.dart';

class EditBillScreen extends StatelessWidget {
  final Bill bill;

  const EditBillScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditBillViewModel(bill),
      child: Consumer<EditBillViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CustomHeader_1(title: tr('edit_bill_title')),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: viewModel.nameController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(50),
                            ],
                            decoration:  InputDecoration(labelText: tr('bill_name_label')),
                            onChanged: viewModel.setName,
                            maxLines: null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<Repeat>(
                            value: viewModel.selectedRepeat,
                            items: viewModel.repeatOptions
                                .map((option) => DropdownMenuItem<Repeat>(
                                      value: option,
                                      child:
                                          Text(getRepeatString(option)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.setSelectedRepeat(value);
                              }
                            },
                            decoration:  InputDecoration(
                              labelText: tr('repeat_label'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  controller: viewModel.dateController,
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      locale: context.locale,
                                      context: context,
                                      initialDate: viewModel.selectedDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null &&
                                        picked != viewModel.selectedDate) {
                                      viewModel.setSelectedDate(picked);
                                    }
                                  },
                                  decoration:  InputDecoration(
                                    labelText: tr('select_date'),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: viewModel.hourController,
                                  readOnly: true,
                                  onTap: () async {
                                    final TimeOfDay? picked = await showTimePicker(
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
                          TextField(
                            controller: viewModel.noteController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(120),
                            ],
                            onChanged: (value) {
                              viewModel.setNote(value);
                            },
                            decoration:  InputDecoration(
                              labelText: tr('note_label'),
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: null,
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: CustomElevatedButton_2(
                              onPressed: viewModel.enableButton
                                  ? () async {
                                      final updatedBill = await viewModel
                                          .updateBill(bill.billId, bill.createdAt);
                                      if (updatedBill != null) {
                                        await CustomSnackBar_2.show(
                                            context, tr('edit_success_message'));
                                        Navigator.pop(context, updatedBill);
                                      }
                                    }
                                  : null,
                              text: tr('save_button'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
