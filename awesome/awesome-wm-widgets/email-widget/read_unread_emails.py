#!/usr/bin/env python3

import sys
import imaplib
import email.header
import datetime

def decode_mime_words(s):
    return ''.join(
        word.decode(encoding or 'utf8') if isinstance(word, bytes) else word
        for word, encoding in email.header.decode_header(s))

def process_mailbox(mailbox, to = None):
    rv, data = mailbox.search(None, "(UNSEEN)")
    if rv != 'OK':
        print("No messages found!")
        return False

    split = data[0].split()

    if len(split) == 0:
        return False

    for num in split:
        rv, data = mailbox.fetch(num, '(BODY.PEEK[])')
        if rv != 'OK':
            print("ERROR getting message", num)
            return False

        msg = email.message_from_bytes(data[0][1])

        if to is not None:
            print('To: ', to)

        print('From:', msg['From'])

        subject = decode_mime_words(msg['Subject'])

        print('Subject: %s' % subject)
        date_tuple = email.utils.parsedate_tz(msg['Date'])
        if date_tuple:
            local_date = datetime.datetime.fromtimestamp(email.utils.mktime_tz(date_tuple))
            print("Local Date:", local_date.strftime("%a, %d %b %Y %H:%M:%S"))
            print()

    return True

try:
    import credentials
except:
    print("Couldn't read crendtials")
    exit(1)

for account in credentials.accounts:

    mailbox = imaplib.IMAP4_SSL(account.host, 993)
    mailbox.login(account.username, account.password)

    rv, data = mailbox.select("INBOX")

    if rv == 'OK':
        if process_mailbox(mailbox, account.email):
            print(account.link, file=sys.stderr)

    mailbox.close()
    mailbox.logout()
