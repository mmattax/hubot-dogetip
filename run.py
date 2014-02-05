#!/usr/bin/python
from dogetip import app
app.run(
  debug=app.config['DEBUG'],
  host=app.config['HOST'],
  port=app.config['PORT']
)
