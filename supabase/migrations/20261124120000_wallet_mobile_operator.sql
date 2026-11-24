alter table public.wallets
  add column mobile_operator text
  constraint wallets_mobile_operator_check check (
    mobile_operator is null
    or (kind = 3 and mobile_operator in ('mpesa', 'orange_money', 'airtel_money', 'afrimoney'))
  );
