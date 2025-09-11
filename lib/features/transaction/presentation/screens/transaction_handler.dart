import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_amount_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_form_text_field.dart';
import '../../../../core/widgets/custom_suggestion_text_field.dart';
import '../../domain/entities/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/segment_control.dart';

class TransactionHandler extends StatefulWidget {
  const TransactionHandler({super.key});

  @override
  State<TransactionHandler> createState() => _TransactionHandlerState();
}

class _TransactionHandlerState extends State<TransactionHandler> {
  final TextEditingController _name = TextEditingController(),
      _type = TextEditingController(),
      _date = TextEditingController(),
      _amount = TextEditingController(),
      _currency = TextEditingController(),
      _beneficiary = TextEditingController(),
      _sender = TextEditingController(),
      _note = TextEditingController();

  final List<TextEditingController> _beneficiaryList = [];
  bool loading = false;

  late SegmentedControlController _segmentedType;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _segmentedType = SegmentedControlController();
    _segmentedType.addListener(_onSegmentChanged);
    _type.text = _segmentedType.selectedValue;
    context.read<TransactionBloc>().add(GetLinkedUsersRequested());
  }

  @override
  void dispose() {
    _segmentedType.removeListener(_onSegmentChanged);
    _segmentedType.dispose();
    super.dispose();
  }

  void _onSegmentChanged() {
    setState(() {
      _type.text = _segmentedType.selectedValue;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _beneficiaryList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionCreated) {
          NotificationHelper.showSuccessNotification(context, state.toString());
        } else if (state is TransactionError) {
          NotificationHelper.showFailureNotification(context, state.failure.message);
        }
      },
      builder: (context, state) {
        List<String> linkedUserEmails = [];

        if (state is TransactionLinkedUsersLoaded) {
          linkedUserEmails = state.users.map((user) => user.email).toList();
        }
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Add transaction',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              SegmentedControlWidget(controller: _segmentedType),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _name,
                label: "Title",
                hint: 'Enter transaction name',
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomAmountField(amount: _amount, currency: _currency),
                ],
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _note,
                label: "Note",
                hint: 'Add a note (optional)',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Paid by",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        CustomSuggestionTextField(
                          controller: _sender,
                          hintText: 'Enter sender name',
                          options: linkedUserEmails,
                          isVisible: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "When",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        CustomFormTextField(
                          controller: _date,
                          hintText: 'DD/MM/YYYY',
                          inputType: TextInputType.datetime,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Beneficiary",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomSuggestionTextField(
                    controller: _beneficiary,
                    onAdd: () {
                      if (_beneficiary.text.trim().isEmpty) return;

                      setState(() {
                        _beneficiaryList.add(
                          TextEditingController(text: _beneficiary.text.trim()),
                        );
                        _beneficiary.clear();
                      });
                    },
                    isVisible: _type.text != 'Transfer' ? true : false,
                    hintText: 'Enter beneficiary name',
                    options: linkedUserEmails,
                  ),
                ],
              ),

              _type.text != 'Transfer'
                  ? _beneficiaryList.isNotEmpty
                        ? Column(
                            children: _beneficiaryList.asMap().entries.map((
                              entry,
                            ) {
                              int index = entry.key;
                              TextEditingController controller = entry.value;

                              return SizedBox(
                                width: double.infinity,
                                child: ListTile(
                                  title: Text(
                                    controller.text.isNotEmpty
                                        ? controller.text
                                        : 'Aucun texte',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ), //Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink()
                  : const SizedBox.shrink(),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save',
                loading: state is TransactionLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> beneficiariesMap = {
        for (int i = 0; i < _beneficiaryList.length; i++)
          '$i': _beneficiaryList[i].text,
      };
      final transaction = TransactionModel(
        name: _name.text,
        type: TransactionType.values.firstWhere((e) => e.name == _type.text),
        date: DateTime.now(),
        amount: double.parse(_amount.text),
        currency: Currency.values.firstWhere((e) => e.name == 'EUR'),
        sender: _sender.text,
        beneficiary: beneficiariesMap,
        note: _note.text,
      );
      context.read<TransactionBloc>().add(CreateTransactionEvent(transaction));
    }
  }
}
