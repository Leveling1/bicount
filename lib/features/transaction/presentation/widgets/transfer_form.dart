import 'package:bicount/core/constants/constants.dart';
import 'package:bicount/core/constants/friend_const.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/themes/app_dimens.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/core/widgets/custom_suggestion_text_field.dart';
import 'package:bicount/core/widgets/details_card.dart';
import 'package:bicount/features/authentification/data/models/user.model.dart';
import 'package:bicount/features/main/data/models/friends.model.dart';
import 'package:bicount/features/transaction/domain/entities/create_transaction_request_entity.dart';
import 'package:bicount/features/transaction/domain/services/transaction_split_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/transaction_bloc.dart';

class TransferForm extends StatefulWidget {
  const TransferForm({super.key, required this.user, required this.friends});

  final UserModel? user;
  final List<FriendsModel> friends;

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
      listener: (context, state) {
        if (state is TransactionCreated) {
          NotificationHelper.showSuccessNotification(
            context,
            'Transaction saved successfully.',
          );
          clearForm();
        } else if (state is TransactionError) {
          NotificationHelper.showFailureNotification(
            context,
            state.failure.message,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormField(
                controller: _name,
                label: 'Title',
                hint: 'Enter transaction name',
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomAmountField(amount: _amount, currency: _currency),
                ],
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _note,
                label: 'Note',
                hint: 'Add a note (optional)',
                enableValidator: false,
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paid by',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          CustomSuggestionTextField(
                            controller: _sender,
                            hintText: 'Enter sender name',
                            options: friendNames,
                            isVisible: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: CustomFormField(
                        controller: _date,
                        hint: 'DD/MM/YYYY',
                        inputType: TextInputType.datetime,
                        isDate: true,
                        label: 'When',
                      ),
                    ),
                  ],
                ),
              ),
              CheckboxListTile(
                value: _sender.text.trim().toLowerCase() == 'me',
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _sender.text = 'Me';
                    } else {
                      _sender.clear();
                    }
                  });
                },
                title: Text(
                  "It's me the payer",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beneficiaries',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomSuggestionTextField(
                    controller: _beneficiary,
                    onAdd: _addBeneficiary,
                    isVisible: true,
                    hintText: 'Enter beneficiary name',
                    options: friendNames,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add as many receivers as you want. Use "me" if you are also receiving a share.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (_beneficiaryList.isNotEmpty) ...[
                const SizedBox(height: 16),
                Column(
                  children: _beneficiaryList.asMap().entries.map((entry) {
                    final friend = entry.value;
                    final previewShare =
                        splitPreview.sharesByKey[_beneficiaryKey(friend)];
                    return SizedBox(
                      width: double.infinity,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          friend.username,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: previewShare != null
                            ? Text(
                                'Share: ${previewShare.amount.toStringAsFixed(2)} ${_currency.text.isEmpty ? 'USD' : _currency.text}',
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeBeneficiary(entry.key),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                _SplitModeSection(
                  splitMode: _splitMode,
                  onChanged: (mode) {
                    setState(() {
                      _splitMode = mode;
                      if (mode != TransactionSplitMode.equal) {
                        _seedSplitInputsForCurrentMode(overwrite: false);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _splitMode.helperText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (_splitMode != TransactionSplitMode.equal) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Split details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _seedSplitInputsForCurrentMode(overwrite: true);
                          });
                        },
                        child: const Text('Split equally'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._beneficiaryList.map((friend) {
                    final controller = _splitControllerFor(friend);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SplitInputRow(
                        friend: friend,
                        controller: controller,
                        mode: _splitMode,
                        currency: _currency.text.isEmpty
                            ? 'USD'
                            : _currency.text,
                        onChanged: (_) => setState(() {}),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 12),
                DetailsCard(
                  child: splitPreview.errorMessage != null
                      ? Text(
                          splitPreview.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            ...splitPreview.resolvedSplits.map((split) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        split.beneficiary.username,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    if (split.percentage != null &&
                                        _splitMode !=
                                            TransactionSplitMode.customAmount)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Text(
                                          '${split.percentage!.toStringAsFixed(2)}%',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                    Text(
                                      '${split.amount.toStringAsFixed(2)} ${_currency.text.isEmpty ? 'USD' : _currency.text}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                ),
              ],
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

  void _addBeneficiary() {
    final rawValue = _beneficiary.text.trim();
    if (rawValue.isEmpty) {
      return;
    }

    final beneficiary = _resolveParty(rawValue);
    final beneficiaryKey = _beneficiaryKey(beneficiary);
    final exists = _beneficiaryList.any(
      (friend) => _beneficiaryKey(friend) == beneficiaryKey,
    );
    if (exists) {
      NotificationHelper.showFailureNotification(
        context,
        'This beneficiary is already in the split.',
      );
      return;
    }

    setState(() {
      _beneficiaryList.add(beneficiary);
      _beneficiary.clear();
      _splitControllerFor(beneficiary);
      if (_splitMode != TransactionSplitMode.equal) {
        _seedSplitInputsForCurrentMode(overwrite: false);
      }
    });
  }

  void _removeBeneficiary(int index) {
    setState(() {
      final removed = _beneficiaryList.removeAt(index);
      final key = _beneficiaryKey(removed);
      _splitControllers.remove(key)?.dispose();
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_beneficiaryList.isEmpty && _beneficiary.text.trim().isNotEmpty) {
      _addBeneficiary();
    }

    if (_beneficiaryList.isEmpty) {
      NotificationHelper.showFailureNotification(
        context,
        'Add at least one beneficiary.',
      );
      return;
    }

    final totalAmount = _parseAmount(_amount.text);
    if (totalAmount == null || totalAmount <= 0) {
      NotificationHelper.showFailureNotification(
        context,
        'Enter a valid amount.',
      );
      return;
    }

    try {
      final request = CreateTransactionRequestEntity(
        name: _name.text.trim(),
        date: _resolveTransactionDate(),
        totalAmount: totalAmount,
        currency: _currency.text.isEmpty ? 'USD' : _currency.text,
        sender: _resolveSender(),
        note: _note.text.trim(),
        splitMode: _splitMode,
        splits: _buildSplitInputs(),
      );
      _splitResolver.resolve(request);
      context.read<TransactionBloc>().add(CreateTransactionEvent(request));
    } on MessageFailure catch (error) {
      NotificationHelper.showFailureNotification(context, error.message);
    }
  }

  List<TransactionSplitInputEntity> _buildSplitInputs() {
    return _beneficiaryList.map((friend) {
      final value = _parseAmount(_splitControllerFor(friend).text);
      return TransactionSplitInputEntity(
        beneficiary: friend,
        percentage: _splitMode == TransactionSplitMode.percentage
            ? value
            : null,
        amount: _splitMode == TransactionSplitMode.customAmount ? value : null,
      );
    }).toList();
  }

  FriendsModel _resolveSender() {
    if (_sender.text.trim().isEmpty && widget.user != null) {
      return _toCurrentUserParty();
    }
    return _resolveParty(_sender.text.trim());
  }

  FriendsModel _resolveParty(String rawValue) {
    if (rawValue.trim().toLowerCase() == 'me' && widget.user != null) {
      return _toCurrentUserParty();
    }

    return widget.friends.firstWhere(
      (friend) => friend.username.toLowerCase() == rawValue.toLowerCase(),
      orElse: () => FriendsModel(
        sid: '',
        username: rawValue,
        uid: '',
        image: Constants.memojiDefault,
        email: '',
        relationType: FriendConst.friend,
      ),
    );
  }

  FriendsModel _toCurrentUserParty() {
    final user = widget.user!;
    return FriendsModel(
      sid: user.sid,
      username: user.username,
      uid: user.uid,
      image: user.image,
      email: user.email,
      relationType: FriendConst.friend,
    );
  }

  TextEditingController _splitControllerFor(FriendsModel friend) {
    final key = _beneficiaryKey(friend);
    return _splitControllers.putIfAbsent(key, TextEditingController.new);
  }

  void _seedSplitInputsForCurrentMode({required bool overwrite}) {
    if (_beneficiaryList.isEmpty) {
      return;
    }

    if (_splitMode == TransactionSplitMode.percentage) {
      final count = _beneficiaryList.length;
      var distributed = 0.0;
      for (var index = 0; index < _beneficiaryList.length; index++) {
        final friend = _beneficiaryList[index];
        final controller = _splitControllerFor(friend);
        if (!overwrite && controller.text.trim().isNotEmpty) {
          continue;
        }

        final value = index == count - 1
            ? (100 - distributed)
            : double.parse((100 / count).toStringAsFixed(2));
        distributed += value;
        controller.text = value.toStringAsFixed(2);
      }
      return;
    }

    if (_splitMode == TransactionSplitMode.customAmount) {
      final totalAmount = _parseAmount(_amount.text);
      if (totalAmount == null || totalAmount <= 0) {
        return;
      }

      final previewRequest = CreateTransactionRequestEntity(
        name: _name.text.trim().isEmpty ? 'Preview' : _name.text.trim(),
        date: _resolveTransactionDate(),
        totalAmount: totalAmount,
        currency: _currency.text.isEmpty ? 'USD' : _currency.text,
        sender: widget.user != null
            ? _toCurrentUserParty()
            : _beneficiaryList.first,
        note: _note.text.trim(),
        splitMode: TransactionSplitMode.equal,
        splits: _beneficiaryList
            .map((friend) => TransactionSplitInputEntity(beneficiary: friend))
            .toList(),
      );

      final equalShares = _splitResolver.resolve(previewRequest);
      for (final share in equalShares) {
        final controller = _splitControllerFor(share.beneficiary);
        if (!overwrite && controller.text.trim().isNotEmpty) {
          continue;
        }
        controller.text = share.amount.toStringAsFixed(2);
      }
    }
  }

  _SplitPreviewResult _buildPreview() {
    if (_beneficiaryList.isEmpty) {
      return const _SplitPreviewResult(resolvedSplits: [], sharesByKey: {});
    }

    final totalAmount = _parseAmount(_amount.text);
    if (totalAmount == null || totalAmount <= 0) {
      return const _SplitPreviewResult(
        resolvedSplits: [],
        sharesByKey: {},
        errorMessage: 'Enter a valid total amount to preview the split.',
      );
    }

    try {
      final request = CreateTransactionRequestEntity(
        name: _name.text.trim().isEmpty ? 'Preview' : _name.text.trim(),
        date: _resolveTransactionDate(),
        totalAmount: totalAmount,
        currency: _currency.text.isEmpty ? 'USD' : _currency.text,
        sender: widget.user != null
            ? _toCurrentUserParty()
            : _beneficiaryList.first,
        note: _note.text.trim(),
        splitMode: _splitMode,
        splits: _buildSplitInputs(),
      );
      final resolved = _splitResolver.resolve(request);
      return _SplitPreviewResult(
        resolvedSplits: resolved,
        sharesByKey: {
          for (final split in resolved)
            _beneficiaryKey(split.beneficiary): split,
        },
      );
    } on MessageFailure catch (error) {
      return _SplitPreviewResult(
        resolvedSplits: const [],
        sharesByKey: const {},
        errorMessage: error.message,
      );
    }
  }

  double? _parseAmount(String rawValue) {
    if (rawValue.trim().isEmpty) {
      return null;
    }
    return double.tryParse(rawValue.replaceAll(',', '.'));
  }

  String _resolveTransactionDate() {
    if (_date.text.isEmpty) {
      return DateTime.now().toIso8601String();
    }

    final parsedDate =
        DateTime.tryParse(_date.text) ??
        DateFormat('dd/MM/yy').tryParseStrict(_date.text) ??
        DateFormat('dd/MM/yyyy').tryParseStrict(_date.text);
    if (parsedDate != null) {
      return parsedDate.toIso8601String();
    }

    return DateTime.now().toIso8601String();
  }

  String _beneficiaryKey(FriendsModel friend) {
    if (friend.sid.isNotEmpty) {
      return friend.sid;
    }
    return '${friend.username.toLowerCase()}::${friend.email.toLowerCase()}';
  }

  void clearForm() {
    setState(() {
      _name.clear();
      _date.clear();
      _amount.clear();
      _currency.clear();
      _beneficiary.clear();
      _sender.clear();
      _note.clear();
      _beneficiaryList.clear();
      _splitMode = TransactionSplitMode.equal;
      for (final controller in _splitControllers.values) {
        controller.dispose();
      }
      _splitControllers.clear();
    });
  }
}

class _SplitModeSection extends StatelessWidget {
  const _SplitModeSection({required this.splitMode, required this.onChanged});

  final TransactionSplitMode splitMode;
  final ValueChanged<TransactionSplitMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Split method', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TransactionSplitMode.values.map((mode) {
            return ChoiceChip(
              label: Text(mode.label),
              selected: splitMode == mode,
              onSelected: (_) => onChanged(mode),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SplitInputRow extends StatelessWidget {
  const _SplitInputRow({
    required this.friend,
    required this.controller,
    required this.mode,
    required this.currency,
    required this.onChanged,
  });

  final FriendsModel friend;
  final TextEditingController controller;
  final TransactionSplitMode mode;
  final String currency;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final suffix = mode == TransactionSplitMode.percentage ? '%' : currency;

    return DetailsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.username,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  mode == TransactionSplitMode.percentage
                      ? 'Set the percentage received.'
                      : 'Set the exact amount received.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(suffixText: suffix, hintText: '0.00'),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitPreviewResult {
  const _SplitPreviewResult({
    required this.resolvedSplits,
    required this.sharesByKey,
    this.errorMessage,
  });

  final List<ResolvedTransactionSplitEntity> resolvedSplits;
  final Map<String, ResolvedTransactionSplitEntity> sharesByKey;
  final String? errorMessage;
}
