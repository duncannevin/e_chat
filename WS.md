# Room Socket

For receiving updates to the room server.

**URL** : `/ws/rooms/<room name>`

## Incoming Messages 

**Content example**

```json
{
    "action": "room",
    "data": {
      "name": "Thunder Room",
      "messages": [...]
    }
}
```

# Rooms Socket

For receiving updates to the rooms server.

**URL** : `/ws/rooms`

## Incoming Messages 

**Content example**

```json
{
    "action": "roomnames",
    "data": ["Thunder Room", "Another Room", "You get the point"] 
}
```
