"""
This script uses boto3 to:
  - Retrieve instances with tags that have a TTL which will expire in one or three days and notify the owner
  - Retrieve instances with tags that have a TTL which is set in the past.

Used for temporary environments.
"""

import boto3
import smtplib
import re
from botocore.config import Config
from datetime import datetime
from email.message import EmailMessage
from string import Template
from smtplib import SMTPRecipientsRefused

CONFIG = Config(region_name = "eu-west-1")
EMAIL_SENDER = "reaqtasaasprovisioning@ibm.com"
MAIL_SERVER = "emea.relay.ibm.com"
MAIL_PORT = 25


def get_tag(tags, key):
    if not tags:
        return ''
    for tag in tags:
        if tag['Key'] == key:
            return tag['Value']
    return ''


def is_expired(ttl):
    return datetime.strptime(ttl, '%Y-%m-%d %H:%M:%S') < datetime.now()


def is_running(state):
    return state["Name"] in ["running", "stopped"]

def get_expired_instances(instances):
    expired = []
    for instance in instances:
        ttl = get_tag(instance.tags, "TTL")
        # Only select instances that have the TTL tag and are not terminated already
        if ttl and is_expired(ttl) and is_running(instance.state):
            expired.append(instance)

    return expired


def check_soon_to_expire_instances(instances_object):
    to_be_expired = []
    owner_list = []

    for instance in instances_object:
        ttl = get_tag(instance.tags, "TTL")
        owner = get_tag(instance.tags, "Owner")
        name = get_tag(instance.tags, "Name")

        if ttl and is_running(instance.state):
            d0 = datetime.now()
            d1 = datetime.strptime(ttl, '%Y-%m-%d %H:%M:%S')
            delta = d1 - d0
            if delta.days == 3 or delta.days == 1:
                to_be_expired.append({"instance_id": instance.id, "name": name, "owner": owner, "days_to_expire": delta.days})
                owner_list.append(owner)

    owner_list = list(set(owner_list))  # Removing duplicates
    final_list = []

    for owner in owner_list:
        owner_items = []
        for item in to_be_expired:
            if owner == item['owner']:
                owner_items.append(item)
        final_list.append(owner_items)

    for item in final_list:
        recipient = item[0]['owner']
        msg = ""

        for target_instance in item:
            if target_instance["days_to_expire"] == 1:
                timeframe = '<b>tomorrow</b>'
            else:
                timeframe = f'in <b>{str(target_instance["days_to_expire"])}</b> days'

            msg = msg + f'- <b>{target_instance["name"]}</b> ({target_instance["instance_id"]}) will be terminated {timeframe}<br>'

        send_notification(content=msg, mail_recipient=recipient)


def send_notification(content, mail_recipient):
    email_sender = EMAIL_SENDER
    server = MAIL_SERVER
    port = MAIL_PORT
    email_recipient = mail_recipient

    body = update_mail_template(template_path="email_template/instance_termination_notice.html", content=content)

    mail_msg = EmailMessage()
    mail_msg["Subject"] = "Impending staging servers termination"
    mail_msg["From"] = email_sender
    mail_msg["To"] = email_recipient
    mail_msg.set_content(body, subtype="html")

# Validate recipient email address
def validate_email(email):
    # Check if email is not empty
    if not email:
        return False
    # Check basic formatting
    if not re.match(r"[^@]+@[^@]+\.[^@]+", email):
        return False
    return True

recipient_email = mail_recipient

if not validate_email(recipient_email):
    print("Invalid recipient email address")
else:
    try:
        with smtplib.SMTP(server, port) as smtp_server:
            smtp_server.send_message(mail_msg)
    except SMTPException as e:
        # Handle any SMTP-related errors
        print(f"Failed to send email: {e}")
    except Exception as e:
        # Handle any other unexpected errors
        print(f"An unexpected error occurred: {e}")


def update_mail_template(template_path, content):

    with open(template_path, "r") as f:
        source = Template(f.read())
        output = source.substitute(
            {
                "content": content
            }
        )

    return output


if __name__ == '__main__':
    client = boto3.resource('ec2', config=CONFIG)
    instances = client.instances.filter()
    check_soon_to_expire_instances(instances_object=instances)
    expired_instances = get_expired_instances(instances)
    for instance in expired_instances:
        print(get_tag(instance.tags, "Name"))