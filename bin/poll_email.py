#!/usr/bin/python3

from O365 import Account
from subprocess import Popen
import time
import re
import datetime

client_id=''
client_secret=''

credentials = (client_id, client_secret)

# the default protocol will be Microsoft Graph
# the default authentication method will be "on behalf of a user"

account = Account(credentials)
if not account.is_authenticated:
    account.authenticate(scopes=['basic', 'mailbox', 'https://graph.microsoft.com/Mail.ReadWrite'])
    print('Authenticated!')


mailbox = account.mailbox()
ci = mailbox.get_folder(folder_name='Continues Integration')
di = mailbox.get_folder(folder_name='Deleted Items')
jenkins = ci.get_folder(folder_name='Jenkins')
last_query = None

while True:
    query = mailbox.new_query().on_attribute('subject').startswith('Change in')

    if last_query is not None:
        query = query.chain('and').on_attribute('created_date_time').greater(last_query)
    last_query = datetime.datetime.now()

    messages = jenkins.get_messages(query=query)

    url_regex = r"[Ss]tarted:?.*\s*(https?://[^\s<]+)"
    for message in messages:
        print(message.subject)
        #print(message.body)
        groups = re.search(url_regex, message.body, re.MULTILINE)
        if groups is not None:
            print("Matched!")
            Popen(['jenkins_watcher', groups.group(1)])
            message.move(di)
    time.sleep(600)
