from sqlalchemy import String
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

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

engine = create_engine("sqlite:///dev.db", echo=True)
Base.metadata.create_all(engine)
