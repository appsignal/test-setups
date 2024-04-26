from sqlalchemy import String
from sqlalchemy import create_engine
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import Session

class Base(DeclarativeBase):
    pass

class Book(Base):
    __tablename__ = "books"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
    author: Mapped[str] = mapped_column(String(50))

    def __repr__(self) -> str:
        return f"Book(id={self.id!r}, name={self.name!r}, author={self.author!r})"
    
    def as_dict(self) -> dict:
        return {"id": self.id, "name": self.name, "author": self.author}

def _init_db():
    engine = create_engine("sqlite:///dev.db", echo=True)
    Base.metadata.create_all(engine)

    try:
        with Session(engine) as session:
            book = Book(
                id=1,
                name="The Great Gatsby",
                author="F. Scott Fitzgerald"
            )
            session.add(book)
            session.commit()
    except IntegrityError:
        pass

    return engine

engine = _init_db()
