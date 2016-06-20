#/bin/bash
# Uses that Smartctl (from smartmontools package) to test disk health

email=Your Email address
logfile=/var/log/autoSmartTest.log

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


if [ "$1" = "short" ]
then
    sleep 5m    # Change this to more time if needed.
    echo "$(date) - As this is a short self test the system will wait 5 minutes for the test to complete" >> $logfile
else
    sleep 2h    # Change this to more time if needed.
    echo "$(date) - As this is a long self test the system will wait 5 minutes for the test to complete" >> $logfile
fi


echo "$(date) - $1 SMART self test complete, sending log to administrator" >> $logfile


( sudo smartctl -l selftest /dev/sda; echo "Full SMART status:"; sudo smartctl -a /dev/sda ) | mailx -s "$1 SMART test completed on $(hostname)." $email

if [ $? -eq 0 ]
then
    echo "$(date) - Email to $email sent successfully" >> $logfile
    exit 0
else
    echo "$(date) - There was a problem sending an email to $email" >> $logfile
    exit 1
fi
