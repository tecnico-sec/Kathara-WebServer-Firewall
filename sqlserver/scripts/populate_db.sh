#!/bin/sh


mysql -u root -e "CREATE DATABASE sirs;"
mysql -u root -D sirs -e "CREATE TABLE exams(id INT AUTO_INCREMENT PRIMARY KEY, question TEXT, answer TEXT, publish_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

# Past exam questions:
#
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Which questions should I answer?', 'All');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Why didnt I study more?', 'Call of duty black ops cold war zombies');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Why didnt I get more study last night?', 'Call of duty black ops cold war zombies');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Why didnt I drink more coffee this morning?', 'Why didnt I drink less coffee this morning?');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Is it too late to drop this course?', 'Yes');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('How much time is the exam?', '90 minutes');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Should I prepare the labs beforehand?', 'Yes');"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer) VALUES ('Did I prepare this labs beforehand?', 'Yes, of course! I am finishing it right now!');"

# Future exam questions:
#
mysql -u root -D sirs -e "INSERT INTO exams(question, answer, publish_date) VALUES ('Should we publish future exam questions online?', 'Why not?', now() + interval 180 day);"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer, publish_date) VALUES ('Should we implement a firewall to protect them from students?', 'Definitely!', now() + interval 180 day);"
mysql -u root -D sirs -e "INSERT INTO exams(question, answer, publish_date) VALUES ('How do we implement a firewall?', 'Check README.md!', now() + interval 180 day);"

mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root' IDENTIFIED BY 'password';"
mysql -u root -ppassword -e "SELECT 1;"
