This application is a simple, lightweight Book Management API built with FastAPI and SQLAlchemy.

http://0.0.0.0:8000/docs

### GET /

The root endpoint that returns a welcome greeting.

### GET /create_book

This endpoint displays the form for creating a new book.

### POST /books

This endpoint creates a new book with the provided title, author, and description. On success, it redirects to the /books endpoint.

### GET /books

This endpoint lists all the books in the collection.

### GET /books/{book_id}

This endpoint displays the details of a single book specified by the book_id.

### GET /books/{book_id}/update

This endpoint displays a form for updating the details of a single book specified by the book_id.

### POST /books/{book_id}/update

This endpoint accepts form data and updates the details of the specified book. On success, it redirects to the book detail view of the updated book.

### DELETE /books/{book_id}

This endpoint deletes the specified book from the collection.
