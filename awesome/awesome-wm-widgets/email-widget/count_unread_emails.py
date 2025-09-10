#!/usr/bin/env python3

import imaplib
import email
import sys

try:
    import credentials
except:
    print("Couldn't read crendtials")
    exit(1)

ok = True
unread = 0

for account in credentials.accounts:

    mailbox = imaplib.IMAP4_SSL(account.host, 993)
    mailbox.login(account.username, account.password)

    status, counts = mailbox.status("INBOX","(MESSAGES UNSEEN)")

    if status == "OK":
        unread += int(counts[0].split()[4][:-1])
    else:
        ok = False

if not ok and unread == 0:
    print('N/A')
else:
    print(unread)
