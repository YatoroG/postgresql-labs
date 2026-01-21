-- Найти активные счета в EUR, открытые после 2024-01-01, отсортировать по дате открытия
SELECT account_id, account_type, status, currency, opened_at
FROM accounts
WHERE currency = 'EUR' AND opened_at > '2024-01-01' AND status = 'active'
ORDER BY opened_at ASC;

-- Вывести ФИО клиента, тип счета, валюту и статус счета
SELECT clients.full_name, accounts.account_type, accounts.currency, accounts.status
FROM accounts
INNER JOIN clients on accounts.client_id = clients.client_id;

-- Вывести всех клиентов и количество их счетов (включая 0)
SELECT clients.client_id, clients.full_name, COUNT(accounts.account_id) AS accounts_number
FROM clients
LEFT JOIN accounts on clients.client_id = accounts.client_id
GROUP BY clients.client_id, clients.full_name
ORDER BY clients.client_id;

-- Найти клиентов, у которых больше 2 активных счетов
SELECT clients.client_id, clients.full_name, COUNT(accounts.account_id) AS active_accounts_number
FROM clients
INNER JOIN accounts on clients.client_id = accounts.client_id
WHERE accounts.status = 'active'
GROUP BY clients.client_id, clients.full_name
HAVING COUNT(accounts.account_id) >= 2;

-- Найти счета, у которых сумма входящих операций (deposit + transfer_in) выше среднего по банку
SELECT transactions.account_id, SUM(transactions.amount) AS deposit_and_transfer_in_sum
FROM transactions
WHERE txn_type = 'transfer_in' OR txn_type = 'deposit'
GROUP BY transactions.account_id
HAVING SUM(transactions.amount) > (
	SELECT AVG(transactions.amount)
	FROM transactions
	WHERE txn_type = 'transfer_in' OR txn_type = 'deposit'
);

-- Топ-5 клиентов по сумме всех операций (оборот) за 2025 год
SELECT clients.full_name, SUM(transactions.amount) AS overall_amount_in_2025
FROM accounts
INNER JOIN clients on accounts.client_id = clients.client_id
INNER JOIN transactions on accounts.account_id = transactions.account_id
WHERE transactions.txn_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY clients.full_name
ORDER BY overall_amount_in_2025 DESC
LIMIT 5;

-- Определить “активность клиента” по количеству операций за последние 90 дней:
-- 0 операций → inactive
-- 1–5 → low
-- 6–20 → medium
-- 20 → high
SELECT clients.full_name, COUNT(transactions.transaction_id) AS amount_for_the_last_90_days,
	CASE 
		WHEN COUNT(transactions.transaction_id) > 20 THEN 'high'
		WHEN COUNT(transactions.transaction_id) >= 6 THEN 'medium'
		WHEN COUNT(transactions.transaction_id) >= 1 THEN 'low'
		ELSE 'inactive'
	END AS client_activity
FROM accounts
INNER JOIN clients on accounts.client_id = clients.client_id
INNER JOIN transactions on accounts.account_id = transactions.account_id
WHERE transactions.txn_date >= CURRENT_TIMESTAMP - INTERVAL '90 days'
GROUP BY clients.client_id;

-- Найти кредиты, по которым сумма успешных платежей < 50% от principal
SELECT loans.loan_id, loans.principal, SUM(loan_payments.amount) AS already_paid
FROM loans
INNER JOIN loan_payments ON loans.loan_id = loan_payments.loan_id
WHERE loan_payments.status = 'success' 
GROUP BY loans.loan_id,  loans.principal
HAVING SUM(loan_payments.amount) < loans.principal * 0.5;

-- Показать все активные карты и кому они принадлежат (ФИО, account_id, срок действия)
SELECT clients.full_name, accounts.account_id, cards.card_id, cards.issued_at, cards.expires_at, cards.status
FROM accounts
INNER JOIN clients on clients.client_id = accounts.client_id
INNER JOIN cards on accounts.account_id = cards.account_id
WHERE cards.status = 'active'

-- Для каждого счета посчитать: количество операций и сумму списаний (withdrawal + transfer_out + fee)
SELECT txn1.account_id, COUNT(txn1.transaction_id), 
(
	SELECT COALESCE(SUM(txn2.amount), 0)
	FROM transactions txn2
	WHERE txn1.account_id = txn2.account_id AND txn2.txn_type IN ('withdrawal', 'transfer_out', 'fee')
) AS overall_withdrawal_amount
FROM transactions txn1
GROUP BY txn1.account_id;
