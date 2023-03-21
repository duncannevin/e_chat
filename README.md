# EChat

A simple chat built with elixir. It is fronted with a cowboy http server. This purpose of this application is to build an application without the Pheonix framework before I start learning about that technology.

## How it works

When a user enters their name they are added to the `user_server` state. The user can then add a room which creates a child process in the `room_supervisor` that matches the name of the room, e.g. user enters name "Thunder Room" the process the room will be named `:"Thunder Room".

The socket pids are set in the rooms process. Updating the sockets connected to a given room is handled with the `room_server`. Currently this is triggered in the room controller anytime a post request is made to update a rooms messages.

As it stands now all updates to the rooms are handled via http request, these updates will emit the appropriate ws message back to the client so that the client can make the appropriate updates to the ui.

### Http

Http requests are used for getting the initial state as well as handling all of the updates. The client will recieve a message via websocket for updates to the ui after the initial page load. For route information checkout [the api documentation](API.md).

### WS

The websockets for this project are only used to update the clients after changes are made via websocket post and put requests. This design decision was made to provide a clear contract between the backend and frontend interactions. Websockets will update all users connected to a given room, including the sender, and since the sender updates the backend via websocket we don't have to worry about re-render on the client. To learn more about the specifics checkout [the ws documentation](WS.md).

## Startup

```
mix run --no-halt
```

## Testing

```
mix test
```
