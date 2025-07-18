import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_form_text_field.dart';
import '../widgets/segment_control.dart';

class TransactionHandler extends StatefulWidget {
  const TransactionHandler({super.key});

  @override
  State<TransactionHandler> createState() => _TransactionHandlerState();
}

class _TransactionHandlerState extends State<TransactionHandler> {
  final TextEditingController _name = TextEditingController(),
  _date = TextEditingController(),
  _amount = TextEditingController(),
  _sender = TextEditingController(),
  _beneficiary = TextEditingController(),
  _note = TextEditingController();
  bool loading = false;

  late SegmentedControlController _type;

  @override
  void initState() {
    super.initState();
    _type = SegmentedControlController();
    _type.addListener(_onSegmentChanged);
  }

  @override
  void dispose() {
    _type.removeListener(_onSegmentChanged);
    _type.dispose();
    super.dispose();
  }

  void _onSegmentChanged() {
    print('Segment sélectionné: ${_type.selectedValue}');
    // Ici vous pouvez ajouter votre logique métier
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Text(
            'Add transaction',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),
          SegmentedControlWidget(controller: _type),
          const SizedBox(height: 16),
          CustomFormTextField( //widget.textController,
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
            loading: loading,
            onPressed: () {
              // TODO: Implement save logic
              print('Nom: ${_name.text}');
              print('Date: ${_date.text}');
              print('Montant: ${_amount.text}');
              print('Expéditeur: ${_sender.text}');
              print('Bénéficiaire: ${_beneficiary.text}');
              print('Note: ${_note.text}');
            },
          ),
          const SizedBox(height: 32),
        ],
      )
    );
  }
}
