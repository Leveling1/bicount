-- Reference values only; execute exclusively in the isolated preproduction DB.
insert into public.transaction_type (id, name) values
  (0, 'Expense'), (1, 'Income'), (2, 'Subscription'), (3, 'Salary'),
  (4, 'Other recurring expense'), (5, 'Other recurring income'), (6, 'debt')
on conflict (id) do nothing;
insert into public.friend_type (id, name) values
  (0, 'friend'), (1, 'subcription'), (2, 'workFriend'), (3, 'company')
on conflict (id) do nothing;
insert into public.debt_state (id, name) values
  (0, 'active'), (1, 'partial'), (2, 'paid'), (3, 'overdue'), (4, 'cancelled')
on conflict (id) do nothing;
insert into public.recurring_transfert_frequency (id, name) values
  (0, 'Weekly'), (1, 'Monthly'), (2, 'Quarterly'), (3, 'Yearly')
on conflict (id) do nothing;
insert into public.friend_invites_statut (id, code, label) values
  (0, 'pending', 'Pending'), (1, 'accepted', 'Accepted'),
  (2, 'rejected', 'Rejected'), (3, 'expired', 'Expired')
on conflict (id) do nothing;
insert into public.notification_type (id, label) values
  (0, 'broadcast'), (1, 'personal'), (2, 'group')
on conflict (id) do nothing;
insert into public.currencies (code, name, symbol, display_order) values
  ('CDF', 'Franc congolais', 'CDF', 0), ('USD', 'US dollar', 'USD', 1),
  ('EUR', 'Euro', 'EUR', 2), ('CAD', 'Dollar canadien', 'CAD', 3)
on conflict (code) do nothing;
