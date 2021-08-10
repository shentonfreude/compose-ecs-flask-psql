#!/usr/bin/python

import os
import random
import string

from flask import Flask, request
from sqlalchemy import Table, Column, Integer, String, MetaData, create_engine, sql

app = Flask(__name__)

DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]
DB_HOST = os.environ["DB_HOST"]
DB_PORT = os.environ["DB_PORT"]
DB_NAME = os.environ["DB_NAME"]

engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
conn = engine.connect()
metadata = MetaData()
users = Table(
    'users', metadata,
    Column('id', Integer, primary_key=True),
    Column('name', String),
)


@app.route("/")
def hello():
    return "Try urls: /createtable, /insert, /select"


@app.route("/createtable")
def createtable():
    res = metadata.create_all(engine)
    return f"{res=}"


@app.route("/insert")
def insert():
    name = ''.join(random.choices(string.ascii_lowercase, k=10))
    insert = users.insert().values(name=name)
    res = conn.execute(insert)
    return({res.inserted_primary_key[0]: name})


@app.route("/select")
def select():
    res = conn.execute(sql.select(users))
    return {id: name for id, name in res}


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=80, debug=True)
