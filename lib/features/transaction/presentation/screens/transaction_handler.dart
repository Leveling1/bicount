import 'package:bicount/features/transaction/domain/entities/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_form_text_field.dart';
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
      _sender = TextEditingController(),
      _beneficiary = TextEditingController(),
      _note = TextEditingController();
  bool loading = false;

  late SegmentedControlController _segmentedType;

  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _segmentedType = SegmentedControlController();
    _segmentedType.addListener(_onSegmentChanged);
    _type.text = _segmentedType.selectedValue;
  }

  @override
  void dispose() {
    _segmentedType.removeListener(_onSegmentChanged);
    _segmentedType.dispose();
    super.dispose();
  }

  void _onSegmentChanged() {
    _type.text = _segmentedType.selectedValue;
    // Ici vous pouvez ajouter votre logique métier
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is TransactionFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Add transaction',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              SegmentedControlWidget(controller: _type),
              const SizedBox(height: 16),
              CustomFormTextField(
                //widget.textController,
                hintText: 'Enter transaction name',
                onChanged: (value) => _name.text = value,
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                hintText: 'DD/MM/YYYY',
                inputType: TextInputType.datetime,
                onChanged: (value) => _date.text = value,
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                hintText: 'Enter amount',
                inputType: TextInputType.number,
                onChanged: (value) => _amount.text = value,
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                hintText: 'Enter sender name',
                onChanged: (value) => _sender.text = value,
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                hintText: 'Enter beneficiary name',
                onChanged: (value) => _beneficiary.text = value,
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                hintText: 'Add a note (optional)',
                inputType: TextInputType.multiline,
                onChanged: (value) => _note.text = value,
              ),
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
      final transaction = TransactionModel(
        name: _name.text,
        type: _type.text,
        date: date,
        createdAt: DateTime.now(),
        amount: double.parse(_amount.text),
        sender: _sender.text,
        beneficiary: _beneficiary.text,
        note: _note.text,
      );
      context.read<TransactionBloc>().add(CreateTransactionEvent(transaction));
    }
  }
}
