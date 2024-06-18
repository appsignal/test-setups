# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
import appsignal
appsignal.start()

import pika

from flask import Flask, request
app = Flask(__name__)

@app.route("/")
def home():
    return """
        <h1>Python Flask + Pika OpenTelemetry app</h1>
        <ul>
        <li><a href="/publish_rabbit">Publish a message to RabbitMQ</a></li>
        </ul>
    """

@app.route("/publish_rabbit")
def publish_rabbit():
    pika_connection = pika.BlockingConnection(pika.URLParameters('amqp://rabbitmq'))
    pika_channel = pika_connection.channel()
    pika_channel.basic_publish(exchange='', routing_key='test', body=b'Hello World!')
    pika_connection.close()

    return "<p>Published a message to RabbitMQ!</p>"
