import appsignal
from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
import os

appsignal.start()

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
async def root():
    return """
      <h1>Python database adapters test setup</h1>

      <ul>
        <li><a href="/aiopg">/aiopg: Connect to PostgreSQL and perform a query using <kbd>aiopg</kbd></a></li>
        <li><a href="/asyncpg">/asyncpg: Connect to PostgreSQL and perform a query using <kbd>asyncpg</kbd></a></li>
        <li><a href="/psycopg2">/psycopg2: Connect to PostgreSQL and perform a query using <kbd>psycopg2</kbd></a></li>
        <li><a href="/psycopg">/psycopg: Connect to PostgreSQL and perform a query using <kbd>psycopg</kbd></a></li>
      </ul>
      <ul>
        <li><a href="/mysql">/mysql: Connect to MySQL and perform a query using <kbd>mysql</kbd></a></li>
        <li><a href="/mysqlclient">/mysqlclient: Connect to MySQL and perform a query using <kbd>mysqlclient</kbd></a></li>
        <li><a href="/pymysql">/pymysql: Connect to MySQL and perform a query using <kbd>pymysql</kbd></a></li>
      </ul>
      <ul>
        <li><a href="/sqlite3">/sqlite3: Connect to SQLite and perform a query using <kbd>sqlite3</kbd></a></li>
      </ul>
      <ul>
        <li><a href="/slow">/slow: Trigger a slow request</a></li>
        <li><a href="/error">/error: Trigger an error</a></li>
        <li><a href="/hello/world">/hello/{name}: Use parameterised routing</a></li>
      </ul>
    """

@app.get("/aiopg")
async def aiopg_query():
    import aiopg

    async with aiopg.create_pool(
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        database=os.environ["POSTGRES_DB"],
        host=os.environ["POSTGRES_HOST"]
    ) as pool:
        async with pool.acquire() as connection:
            async with connection.cursor() as cursor:
                await cursor.execute("SELECT 1 + 1")
                result = await cursor.fetchone()

                return {"result": result[0]}
    
@app.get("/asyncpg")
async def asyncpg_query():
    import asyncpg

    connection = await asyncpg.connect(
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        database=os.environ["POSTGRES_DB"],
        host=os.environ["POSTGRES_HOST"]
    )

    result = await connection.fetchval("SELECT 1 + 1")
    await connection.close()

    return {"result": result}

@app.get("/psycopg2")
async def psycopg2_query():
    import psycopg2

    connection = psycopg2.connect(
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        database=os.environ["POSTGRES_DB"],
        host=os.environ["POSTGRES_HOST"]
    )

    cursor = connection.cursor()
    cursor.execute("SELECT 1 + 1")
    result = cursor.fetchone()[0]

    cursor.close()
    connection.close()

    return {"result": result}

@app.get("/psycopg")
async def psycopg_query():
    import psycopg

    connection = psycopg.connect(
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        dbname=os.environ["POSTGRES_DB"],
        host=os.environ["POSTGRES_HOST"]
    )

    cursor = connection.cursor()
    cursor.execute("SELECT 1 + 1")
    result = cursor.fetchone()[0]

    cursor.close()
    connection.close()

    return {"result": result}

@app.get("/mysql")
async def mysql_query():
    import mysql.connector

    connection = mysql.connector.connect(
        host=os.environ["MYSQL_HOST"],
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        database=os.environ["MYSQL_DATABASE"]
    )

    cursor = connection.cursor()
    cursor.execute("SELECT 1 + 1")
    result = cursor.fetchone()[0]

    cursor.close()
    connection.close()

    return {"result": result}

@app.get("/pymysql")
async def pymysql_query():
    import pymysql

    connection = pymysql.connect(
        host=os.environ["MYSQL_HOST"],
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        database=os.environ["MYSQL_DATABASE"]
    )

    cursor = connection.cursor()
    cursor.execute("SELECT 1 + 1")
    result = cursor.fetchone()[0]

    cursor.close()
    connection.close()

    return {"result": result}

@app.get("/mysqlclient")
async def mysqlclient_query():
    import MySQLdb

    connection = MySQLdb.connect(
        host=os.environ["MYSQL_HOST"],
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        database=os.environ["MYSQL_DATABASE"]
    )

    cursor = connection.cursor()
    cursor.execute("SELECT 1 + 1")
    result = cursor.fetchone()[0]

    cursor.close()
    connection.close()

    return {"result": result}

@app.get("/sqlite3")
async def sqlite3_query():
    import sqlite3

    connection = sqlite3.connect(":memory:")
    cursor = connection.cursor()
    cursor.execute("SELECT 1 + 1")
    result = cursor.fetchone()[0]

    cursor.close()
    connection.close()

    return {"result": result}

@app.get("/slow")
async def slow():
    import time
    time.sleep(2)
    return {"wow_that_took": "forever"}

@app.get("/error")
async def error():
    raise Exception("I am an error!")

@app.get("/hello/{name}")
async def hello(name):
    return {"greeting": f"Hello, {name}!"}


FastAPIInstrumentor.instrument_app(app)
