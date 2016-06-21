#/bin/bash
# Uses Smartctl (from smartmontools package) to test disk health.
# Tested on Ubuntu 14.04 LTS, but this script is likely to work on many other distributions as well (within reason).
# 
# This script requires that the smartmontools, mailutils, and mailx package to be installed and configured properly.
# 
# Remember to change the below variables to fit your needs (an email will NOT be sent until you do this).
# This script comes with no Warranty and I am not responsible for any damage that this script may cause due to modification or misconfiguration.
# It is recommended that you test this script in a safe environment (like in a VM) before deploying it to any machines that you care about.
#
# After entering the email address you want the script to email to, make sure you run the script using sudo, and include the argument "short" or "long" to specify the level of testing you want.
# Note you can use this script in cron (to make it run automatically), just make sure it runs as the root user and you specify weather it is a short or long self test.

email=Admin@example.com
logfile=/var/log/autoSmartTest.log          # Where your log file should be stored, you can keep this as default.

touch $logfile # Creates log file

sudo smartctl -t $1 /dev/sda > /dev/null


# Checks if the command worked correctly.
if [ $? -eq 0 ]
then
    echo "$(date) - Successfully started $1 SMART self test" >> $logfile
else 
    echo "$(date) - $1 SMART self test failed to start" >> $logfile
    exit 2
fi

# Pauses the script until the self test is done
if [ "$1" = "short" ]
then
    sleep 5m    # Change this to more time if needed.
    echo "$(date) - As this is a short self test the system will wait 5 minutes for the test to complete" >> $logfile
else
    sleep 2h    # Change this to more time if needed.
    echo "$(date) - As this is a long self test the system will wait 5 minutes for the test to complete" >> $logfile
fi


echo "$(date) - $1 SMART self test complete, sending log to administrator" >> $logfile

# Sends email to administrator with test results in the message body
( sudo smartctl -l selftest /dev/sda; echo "Full SMART status:"; sudo smartctl -a /dev/sda ) | mailx -s "$1 SMART test completed on $(hostname)." $email

#Checks if the email sent properly and records it in the log
if [ $? -eq 0 ]
then
    echo "$(date) - Email to $email sent successfully" >> $logfile
    exit 0
else
    echo "$(date) - There was a problem sending an email to $email" >> $logfile
    exit 1
fi
