import appsignal
appsignal.start()

import pika


def on_message(channel, method_frame, header_frame, body):
    print(method_frame.delivery_tag)
    print(body)
    print()
    channel.basic_ack(delivery_tag=method_frame.delivery_tag)


connection = pika.BlockingConnection(pika.URLParameters('amqp://rabbitmq'))
channel = connection.channel()
channel.queue_declare(queue='test')
channel.basic_consume('test', on_message)
try:
    channel.start_consuming()
except KeyboardInterrupt:
    channel.stop_consuming()
    connection.close()
