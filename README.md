# Getting Authenticated

---

To get started, you'll need to create a new user, or log in to an existing account.

## Users and Sessions

---

#### POST /user (sign up)

To create an account, POST to /user with an email and password in the following format:

```
curl -X POST https://any-url.com/user \
  -H 'Content-Type: application/json' \
  -d '{
    "user": {
      "email": "email@example.com",
      "password": "my_password"
    }
  }'
```

Response: 201
```
{
  "data": {
    "email": "email@example.com",
    "token": "pU9BG3fjAkgHAxaPuLo7GJTM"
  }
}
```

#### POST /session (log in)

To fetch an authorization token for an existing user, sign in using the email and password in the following format:

```
curl -X POST https://any-url.com/session \
  -H 'Content-Type: application/json' \
  -d '{
    "user": {
      "email": "email@example.com",
      "password": "my_password"
    }
  }'
```

Response: 201
```
{
  "data": {
    "token": "Mpkz8ZC7Ghq9vKzS5WfAjoVy"
  }
}
```

## Authenticated Routes

---

Both the sign up, and the log in routes return a token. This token can be used to authenticate requests from here in. To authenticate a request, set the Authorization header's value to the value of the token.

Authentication: Mpkz8ZC7Ghq9vKzS5WfAjoVy
note This isn't particularly secure, but is simple enough for the purpose of this test. It's better to use a real session, or a JWT.

### Users

---

#### PUT /user (update your user)

To update your email or password, make a PUT request with the email or password in the following format:

```
curl -X PUT https://any-url.com/user \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Mpkz8ZC7Ghq9vKzS5WfAjoVy' \
  -d '{
    "user": {
      "email": "updated@example.com",
      "password": "my_password"
    }
  }'
```

Response: 200
```
{
  "data": {
    "email": "updated@example.com"
  }
}
```

#### DELETE /user (delete your user)

If you want to remove your user, you can make a DELETE request to the /user route.

```
curl -X DELETE https://any-url.com/user \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Mpkz8ZC7Ghq9vKzS5WfAjoVy'
```

Response: 204, empty

### Sessions

---

#### DELETE /session (log out)

This route approximates log out functionality, by rotating

```
curl -X DELETE https://any-url.com/session \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Mpkz8ZC7Ghq9vKzS5WfAjoVy'
```

Response: 204, empty

### Todos

---

#### GET /todos (get all todos)

Fetches all the todos for the current user.
```
curl -X GET https://any-url.com/todos \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Zm8yaqR9L1r4Y2pBhPhQrBjz'
```

Response: 200
```
{
  "data": [
    {
      "id": 1,
      "title": "New Todo",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2021-10-03T09:30:42.230Z",
      "updated_at": "2021-10-03T09:30:42.230Z"
    }
  ]
}
```

#### POST /todos (create a todo)

Create a new todo by sending the title of the todo in the following format:
```
curl -X POST https://any-url.com/todos \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Zm8yaqR9L1r4Y2pBhPhQrBjz' \
  -d '{
    "todo": {
      "title": "New Todo"
   }
  }'
```

Response: 201
```
{
  "data": {
    "id": 1,
    "title": "New Todo",
    "completed_at": null,
    "user_id": 1,
    "created_at": "2021-10-03T09:30:42.230Z",
    "updated_at": "2021-10-03T09:30:42.230Z"
  }
}
```

#### PUT /todos/:id (update a todo)

Update an existing todo by sending a PUT to /todos/:id where :id is the ID of the todo you want to update. Include the title or completed_at timestamp you want to update in the following format:
```
curl -X PUT https://any-url.com/todos/1 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Zm8yaqR9L1r4Y2pBhPhQrBjz' \
  -d '{
    "todo": {
      "title": "Updated Todo",
      "completed_at": "2021-01-01"
    }
  }'
```

Response: 200
```
{
  "data": {
    "user_id": 1,
    "title": "Updated Todo",
    "completed_at": "2021-01-01T00:00:00.000Z",
    "id": 1,
    "created_at": "2021-10-03T09:30:42.230Z",
    "updated_at": "2021-10-03T09:32:48.591Z"
  }
}
```

#### DELETE /todos:id (delete a todo)

Delete an existing todo by sending a DELETE request to /todos/:id where :id is the ID of the todo you want to delete.
```
curl -X DELETE https://any-url.com/todos/1 \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Zm8yaqR9L1r4Y2pBhPhQrBjz'
```  
Response: 204, empty



