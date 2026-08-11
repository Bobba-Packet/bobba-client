# Bobba backend connection

[← Back to README](../README.md)

The client opens a **second TCP socket** to the Bobba sidecar API (not the Habbo hotel). Habbo game traffic is unchanged.

## Defaults

| Setting | Value |
|---|---|
| Host | `game.bobbapacket.com` |
| Port | `3001` |
| Shared secret | `change-me-bobba-client-secret` (must match backend `.env`) |

For local API testing, set `DEFAULT_HOST` in `BobbaBackendClient.as` to `127.0.0.1` temporarily.

Run the API from `bobba-client-backend`:

```bash
cp .env.example .env
docker compose up --build
```

## Hotel-scoped accounts

Launcher `-server hhbr` / SSO hotel segment is stored as `hotelId` (`hhbr`, `hhes`, …).

Backend accounts are unique on `(hotelId, nickname)`. The same nick on two hotels is two accounts.

The client waits for `sessionDataManager.userName`, then sends nickname (+ figure) in `Hello`. Auth upserts the hotel account so `userId` is assigned before `AuthOK`. `UpdateProfile` remains for later figure/hotel changes.

## Group chat

Hotel-scoped Bobba group chats over the sidecar TCP API.

1. Enable **Chat em grupo** in `:bobba`
2. Run `:groupchat` or `:gc`
3. Create a group, invite by Habbo nickname (invitee must have linked Bobba profile on the same hotel)
4. Invitee gets Accept / Decline confirmation

Messages use Bobba packets only; Habbo hotel chat is unchanged.

## Group whisper

Ephemeral per-room multi-recipient whisper over the same sidecar (packets `60` / `61`).

| ID | Name | Direction | Fields |
|----|------|-----------|--------|
| 60 | `SendRoomWhisper` | C→S | `body`, `recipientsCsv` (comma-separated Habbo nicks) |
| 61 | `RoomWhisper` | S→C | `senderNickname`, `senderFigure`, `body`, `timestamp` |
| 62 | `LookupBobbaUsers` | C→S | `nicknamesCsv` |
| 63 | `BobbaUsersResult` | S→C | count, then each `nickname` + `registered` bool |

The backend fans out to online connections for the same `hotelId` (lookup by nickname). No DB history. The client owns the recipient list and clears it on room enter. The avatar-menu **Sussurro em grupo** button is shown only for nicknames registered in Bobba (`LookupBobbaUsers`).
