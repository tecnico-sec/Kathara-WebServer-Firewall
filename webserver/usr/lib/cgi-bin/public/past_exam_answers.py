#!/usr/bin/python
print('Content-Type: text/plain')
print('')
print("Past exam questions and answers:")

import MySQLdb
db=MySQLdb.connect(host="5.5.5.3",user="root",db="sirs",password="password")
c=db.cursor()
c.execute("""SELECT id, question, answer, publish_date FROM exams WHERE publish_date < NOW()""")
rows = c.fetchall()

for row in rows:
  print(row)