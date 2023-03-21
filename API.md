# Create a Room

For creating a new room server.

**URL** : `/api/room/`

**Method** : `POST`

**Auth required** : NO

**Data constraints**

```json
{
    "roomname": "[the desired room name]",
    "creator": "[a valid username]"
}
```

**Data example**

```json
{
    "roomname": "Thunder Room",
    "creator": "Tester Chester"
}
```

## Success Response

**Code** : `201 OK`

**Content example**

```json
{
    "msg": "Created"
}
```

## Error Response

**Condition** : If 'creator' does not exist.

**Code** : `404 NOT FOUND`

**Content** :

```json
{
    "msg": "User not found"
}
```

## Error Response

**Condition** : If 'roomname' already exists.

**Code** : `400 BAD REQUEST`

**Content** :

```json
{
    "msg": "Duplicate name"
}
```

# Get a List of Room Names

For getting a list of all the room names.

**URL** : `/api/room/`

**Method** : `GET`

**Auth required** : NO

## Success Response

**Code** : `200 OK`

**Content example**

```json
{
    "msg": "Success",
    "rooms": ["Thunder Room", "Best Devs", "General"]
}
```

## Error Response

This endpoint will not fail, it will simply return an empty list of room names in the event of server failure.

# Get a Room 

For creating a new room server.

**URL** : `/api/room/<roomname>`

**Method** : `GET`

**Auth required** : NO

## Success Response

**Code** : `200 OK`

**Content example**

```json
{
    "msg": "Success",
    "roomname": "Thunder Room",
    "messages": [...]
}
```

## Error Response

**Condition** : If 'roomname' does not exist.

**Code** : `404 NOT FOUND`

**Content** :

```json
{
    "msg": "Not found"
}
```
