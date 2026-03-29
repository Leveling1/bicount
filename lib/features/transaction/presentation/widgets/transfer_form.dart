import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/currency/presentation/bloc/currency_cubit.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/entities/transaction_entity.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:bicount/features/transaction/presentation/widgets/split_input_row.dart';
import 'package:bicount/features/transaction/presentation/widgets/split_preview_result.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form_beneficiaries_section.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form_beneficiary_list.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form_party_section.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form_preview_card.dart';
import 'package:bicount/features/transaction/presentation/widgets/transfer_form_split_mode_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_dimens.dart';
import '../bloc/transaction_bloc.dart';

part 'transfer_form_helpers.dart';
part 'transfer_form_interactions.dart';
part 'transfer_form_prefill.dart';
part 'transfer_form_sections.dart';
part 'transfer_form_split_logic.dart';
part 'transfer_form_submission.dart';

class TransferForm extends StatefulWidget {
  const TransferForm({
    super.key,
    required this.user,
    required this.friends,
    this.initialTransaction,
    this.onCompleted,
  });

  final UserModel? user;
  final List<FriendsModel> friends;
  final TransactionEntity? initialTransaction;
  final VoidCallback? onCompleted;

  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _currency = TextEditingController();
  final TextEditingController _beneficiary = TextEditingController();
  final TextEditingController _sender = TextEditingController();
  final TextEditingController _note = TextEditingController();

  final List<FriendsModel> _beneficiaryList = [];
  final Map<String, TextEditingController> _splitControllers = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TransactionSplitResolver _splitResolver =
      const TransactionSplitResolver();

  TransactionSplitMode _splitMode = TransactionSplitMode.equal;
  bool _didPrefillInitialTransaction = false;

  @override
  void initState() => super.initState();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillInitialTransactionIfNeeded();
  }

  @override
  void dispose() {
    _name.dispose();
    _date.dispose();
    _amount.dispose();
    _currency.dispose();
    _beneficiary.dispose();
    _sender.dispose();
    _note.dispose();
    for (final controller in _splitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendNames = widget.friends
        .map((friend) => friend.username)
        .toList();
    final splitPreview = _buildPreview();

    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          current is TransactionCreated ||
          current is TransactionUpdated ||
          current is TransactionError,
      listener: _onTransactionStateChanged,
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: _buildFormBody(
            context,
            state: state,
            friendNames: friendNames,
            splitPreview: splitPreview,
          ),
        );
      },
    );
  }

  void _update(VoidCallback callback) {
    setState(callback);
  }
}
