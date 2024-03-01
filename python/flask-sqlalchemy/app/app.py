# Important to import and start appsignal before any other imports
# otherwise the automatic instrumentation won't work
from __appsignal__ import appsignal
appsignal.start()

from flask import Flask, request
app = Flask(__name__)

from db import Book, engine
from sqlalchemy import select
from sqlalchemy.orm import Session



@app.route("/")
def home():
    return """
        <h1>Python Flask OpenTelemetry app</h1>

        <ul>
        <li><a href="/slow"><kbd>/slow</kbd> &rarr; Trigger a slow request</a></li>
        <li><a href="/error"><kbd>/error</kbd> &rarr; Trigger an error (and use error helpers)</a></li>
        <li><a href="/books"><kbd>/books</kbd> &rarr; List all books from the SQLAlchemy-managed database (as JSON)</a></li>
        <li><a href="/books/new"><kbd>/books/new</kbd> &rarr; Create a book in the SQLAlchemy-managed database (from HTTP POST form)</a></li>
        </ul>
    """

@app.route("/slow")
def slow():
    import time
    time.sleep(2)
    return "<p>Wow, that took forever</p>"

@app.route("/error")
def error():
    class AutomaticallyHandledError(Exception):
        pass

    raise AutomaticallyHandledError("I am an error reported automatically by the Flask instrumentation!")

@app.get("/books")
def list_books():
    with Session(engine) as session:
        statement = select(Book)
        books = session.scalars(statement)
        return [book.as_dict() for book in books]

@app.get("/books/new")
def create_book_form():
    return """
        <h1>Create a new book</h1>
        <form method="post">
            <label for="name">Name:</label>
            <input type="text" name="name" id="name" required>
            <label for="author">Author:</label>
            <input type="text" name="author" id="author" required>
            <button type="submit">Create</button>
        </form>
    """

@app.post("/books/new")
def create_book():
    with Session(engine) as session:
        book = Book(**request.form)
        session.add(book)
        session.commit()
        session.refresh(book)
        return book.as_dict(), 201
