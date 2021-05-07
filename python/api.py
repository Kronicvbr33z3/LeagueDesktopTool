import flask
from flask import request
import os

from flask.helpers import send_from_directory

app = flask.Flask(__name__)
app.config["Debug"] = True

@app.route('/', methods=['GET'])
def home():
    return "<h1> Hello World </h1>"


@app.route('/api/v1/runes', methods=['GET'])
def rune_id():
    if 'id' in request.args:
        id = request.args['id']
    else:
        return "Error: No ID provided"

    try:
        print(id)
        return send_from_directory('/champions', id + ".json")
    except:
        return "Champion not Valid"

            
app.run()