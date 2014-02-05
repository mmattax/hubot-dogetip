from flask import Flask, request, abort
from flask.json import jsonify
import bitcoinrpc
from bitcoinrpc.exceptions import *

app = Flask(__name__)
app.config.from_object('dogetip.config.DefaultConfig')
# Connect to the dogecoin server.
bitcoin = bitcoinrpc.connect_to_remote(
  app.config['RPC_USER'],
  app.config['RPC_PASSWORD'],
  app.config['RPC_HOST'],
  app.config['RPC_PORT']
)

@app.before_request
def before_request():
  if request.remote_addr not in app.config['ALLOWED_IPS']:
    pass
    #abort(403)

@app.route('/balance/<address>')
def balance(address):

  try:
    account = bitcoin.getaccount(address)
    balance = bitcoin.getbalance(account)
  except:
    return jsonify(error='Such unknown balance.')

  return jsonify(balance=str(balance))

@app.route('/tip', methods=['POST'])
def tip():
  try:
    account = bitcoin.getaccount(request.form['from'])
    txid = bitcoin.sendfrom(account, request.form['to'], float(request.form['amount']))
    return jsonify(transaction=txid)
  except InvalidAddressOrKey as e:
    return jsonify(error='Invalid address or key.'), 500
  except (WalletError, InsufficientFunds) as e:
    return jsonify(error='Such low balance. Much more coin needed to tip.'), 500
  except (Exception) as e:
    return jsonify(error='Much errors. Can\'t tip.')
