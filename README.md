# js-openhab-rest-client

A JavaScript client for the openHAB REST API. This library enables easy interaction with the openHAB REST API to control smart home devices, retrieve status information, and process events — directly in the browser or in Node.js.

It mirrors the [python-openhab-rest-client](https://github.com/Michdo93/python-openhab-rest-client) library: same class names, same method names, same usage pattern.

## Features

Supports the following openHAB REST API endpoints:

- Actions
- Addons
- Audio
- Auth
- ChannelTypes
- ConfigDescriptions
- Discovery
- Events (ItemEvents, ThingEvents, InboxEvents, LinkEvents, ChannelEvents)
- Iconsets
- Inbox
- Items
- Links
- Logging
- ModuleTypes
- Persistence
- ProfileTypes
- Rules
- Services
- Sitemaps
- Systeminfo
- Tags
- Templates
- ThingTypes
- Things
- Transformations
- UI
- UUID
- Voice

All classes are also available as `Async` variants (e.g. `AsyncItems`, `AsyncThings`) using `AsyncOpenHABClient`. In JavaScript both are Promise-based and behave identically — the `Async` prefix is purely for naming consistency with the Python library.

Supports both Server-Sent Events (SSE) and regular REST requests. SSE is used for the event streams of openHAB.

## Requirements

- A modern browser with `fetch` and `ReadableStream` support, **or**
- Node.js 18+ (built-in `fetch`)

No external dependencies. The library is a single file (`openhab.js`) with an optional minified version (`openhab.min.js`).

## Installation & Import

There are several ways to include the library, depending on your environment.

### 1. CDN via jsDelivr (recommended for browser)

```html
<script src="https://cdn.jsdelivr.net/gh/Michdo93/js-openhab-rest-client@main/openhab.min.js"></script>
```

Or the unminified version for development:

```html
<script src="https://cdn.jsdelivr.net/gh/Michdo93/js-openhab-rest-client@main/openhab.js"></script>
```

### 2. CDN via GitHack

GitHack serves raw GitHub files with the correct Content-Type:

```html
<script src="https://rawcdn.githack.com/Michdo93/js-openhab-rest-client/main/openhab.min.js"></script>
```

Or unminified:

```html
<script src="https://rawcdn.githack.com/Michdo93/js-openhab-rest-client/main/openhab.js"></script>
```

### 3. GitHub Raw (for testing/development only)

```html
<script src="https://raw.githubusercontent.com/Michdo93/js-openhab-rest-client/main/openhab.js"></script>
```

> **Note:** GitHub Raw does not set the correct `Content-Type` header for JavaScript files, so it may not work in all browsers. Use jsDelivr or GitHack for production.

### 4. Download and host locally

Download `openhab.js` or `openhab.min.js` from the [GitHub repository](https://github.com/Michdo93/js-openhab-rest-client) and place it in your project:

```html
<script src="./openhab.js"></script>
```

### 5. ES Module (browser or bundler)

```html
<script type="module">
  import { OpenHABClient, Items } from "./openhab.js";
  // ...
</script>
```

Or via jsDelivr:

```html
<script type="module">
  import { OpenHABClient, Items } from "https://cdn.jsdelivr.net/gh/Michdo93/js-openhab-rest-client@main/openhab.js";
  // ...
</script>
```

### 6. Node.js (CommonJS)

Download `openhab.js` into your project, then:

```js
const { OpenHABClient, Items } = require("./openhab.js");
```

### 7. Node.js (ES Module)

```js
import { OpenHABClient, Items } from "./openhab.js";
```

---

## Usage

### Accessing exports (browser `<script>` tag)

When loaded via a regular `<script>` tag, all classes are available under the global `window.openHAB` namespace:

```js
const { OpenHABClient, Items, Things, ItemEvents } = openHAB;
```

When loaded as an ES module, you import them directly:

```js
import { OpenHABClient, Items } from "./openhab.js";
```

### Authentication

#### Basic Authentication

```js
const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
```

#### Token-based Authentication

```js
const client = new OpenHABClient(
  "http://127.0.0.1:8080",
  null,
  null,
  "oh.openhab.U0doM1Lz4kJ6tPlVGjH17jjm4ZcTHIHi7sMwESzrIybKbCGySmBMtysPnObQLuLf7PgqnI7jWQ5LosySY8Q"
);
```

#### myopenhab.org Cloud

```js
const client = new OpenHABClient("https://myopenhab.org", "your@email.com", "yourpassword");
```

### Normal REST Requests

All methods return `Promise`s. Use `.then()` or `await`:

```js
const { OpenHABClient, Items } = openHAB;

const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
const itemsAPI = new Items(client);

// With .then()
itemsAPI.getItems().then(items => console.log(items));

// With async/await
async function main() {
  const items = await itemsAPI.getItems();
  console.log(items);
}
main();
```

### Async Variants

The `Async` prefixed classes (`AsyncItems`, `AsyncThings`, etc.) behave identically to the base classes in JavaScript. They exist for naming consistency with the Python library:

```js
const { AsyncOpenHABClient, AsyncItems } = openHAB;

const client = new AsyncOpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
const asyncItems = new AsyncItems(client);

const items = await asyncItems.getItems();
console.log(items);
```

### Verifying Connectivity

Call `login()` to verify the connection before making requests:

```js
await client.login();
if (client.isLoggedIn) {
  console.log("Connected to openHAB");
}
```

### Server-Sent Events (SSE)

SSE streams are returned as a `Promise<Response>`. Consume the stream using the browser's `ReadableStream` API:

```js
const { OpenHABClient, ItemEvents } = openHAB;

const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
const itemEvents = new ItemEvents(client);

const response = await itemEvents.ItemStateChangedEvent();
const reader = response.body.getReader();
const decoder = new TextDecoder();

async function read() {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    const text = decoder.decode(value);
    for (const line of text.split("\n")) {
      if (line.startsWith("data: ")) {
        try {
          const data = JSON.parse(line.slice(6));
          console.log(data);
        } catch {}
      }
    }
  }
}
read();
```

### Complete Browser Example

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdn.jsdelivr.net/gh/Michdo93/js-openhab-rest-client@main/openhab.min.js"></script>
</head>
<body>
<script>
  const { OpenHABClient, Items } = openHAB;

  const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
  const itemsAPI = new Items(client);

  itemsAPI.getItems().then(items => {
    console.log("Items:", items);
  });
</script>
</body>
</html>
```

### Complete ES Module Example

```html
<script type="module">
  import { OpenHABClient, Items, Things } from "https://cdn.jsdelivr.net/gh/Michdo93/js-openhab-rest-client@main/openhab.js";

  const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
  await client.login();

  const itemsAPI = new Items(client);
  const allItems = await itemsAPI.getItems();
  console.log(allItems);

  const things = await new Things(client).getThings();
  console.log(things);
</script>
```

---

## Full List of Methods

---

### OpenHABClient

`OpenHABClient` is the base client class that handles authentication and HTTP communication with the openHAB REST API. All API classes receive an `OpenHABClient` instance in their constructor.

All methods (`get`, `post`, `put`, `delete`) return **Promises**.

#### Constructor

```js
new OpenHABClient(url, username = null, password = null, token = null)
```

**Parameters:**
- `url` (string): The base URL of the openHAB server (e.g. `"http://127.0.0.1:8080"`).
- `username` (string, optional): Username for Basic Authentication.
- `password` (string, optional): Password for Basic Authentication.
- `token` (string, optional): Bearer Token for Token-based Authentication.

**Example:**

```js
const client = new OpenHABClient("http://127.0.0.1:8080", "admin", "password");
```

#### Methods

##### `login()`

Verifies connectivity to the openHAB server. Sets `client.isLoggedIn = true` on success and `client.isCloud = true` when connecting to `myopenhab.org`.

**Returns:** `Promise<OpenHABClient>` (returns itself for chaining).

```js
await client.login();
console.log(client.isLoggedIn); // true
```

##### `get(endpoint, headers = {}, params = null)`

Sends a GET request.

**Parameters:**
- `endpoint` (string): The API endpoint (e.g. `"/items"`).
- `headers` (object, optional): Additional request headers.
- `params` (object, optional): Query parameters.

**Returns:** `Promise<object|string>` — parsed JSON, plain text, or `{ status }` for empty responses.

```js
const items = await client.get("/items");
```

##### `post(endpoint, headers = {}, data = null, params = null)`

Sends a POST request.

**Parameters:**
- `endpoint` (string): The API endpoint.
- `headers` (object, optional): Additional request headers.
- `data` (any, optional): Request body (object or string).
- `params` (object, optional): Query parameters.

**Returns:** `Promise<object|string>`.

##### `put(endpoint, headers = {}, data = null, params = null)`

Sends a PUT request.

**Parameters:** Same as `post`.

**Returns:** `Promise<object|string>`.

##### `delete(endpoint, headers = {}, data = null, params = null)`

Sends a DELETE request.

**Parameters:** Same as `post`.

**Returns:** `Promise<object|string>`.

---

### AsyncOpenHABClient

`AsyncOpenHABClient` extends `OpenHABClient` with an explicit async name for consistency with the Python library. It is functionally identical.

```js
const client = new AsyncOpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
```

---

### Actions

Provides methods to retrieve and execute thing actions.

#### Constructor

```js
const { OpenHABClient, Actions } = openHAB;
const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
const actions = new Actions(client);
```

#### Methods

##### `getActions(thingUID, language = null)`

Gets all available actions for a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `language` (string, optional): Language for the `Accept-Language` header.

**Returns:** `Promise<Array>` — list of available actions.

```js
const actionsList = await actions.getActions("zwave:device:controller:node5");
console.log(actionsList);
```

##### `executeAction(thingUID, actionUID, actionInputs, language = null)`

Executes an action on a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `actionUID` (string): The UID of the action to execute.
- `actionInputs` (object): Input parameters for the action.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object|string>`.

```js
await actions.executeAction("myThingUID", "myActionUID", { param1: "value1" });
```

Also available as `AsyncActions`.

---

### Addons

Provides methods to manage openHAB add-ons.

#### Constructor

```js
const addons = new Addons(client);
```

#### Methods

##### `getAddons(serviceID = null, language = null)`

Gets all available add-ons.

**Parameters:**
- `serviceID` (string, optional): Filter by service ID.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getAddon(addonID, serviceID = null, language = null)`

Gets a specific add-on by ID.

**Parameters:**
- `addonID` (string): The unique identifier of the add-on.
- `serviceID` (string, optional): Filter by service ID.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getAddonConfig(addonID, serviceID = null)`

Gets the configuration of a specific add-on.

**Parameters:**
- `addonID` (string): The unique identifier of the add-on.
- `serviceID` (string, optional): Filter by service ID.

**Returns:** `Promise<object>`.

##### `updateAddonConfig(addonID, configData, serviceID = null)`

Updates the configuration of a specific add-on.

**Parameters:**
- `addonID` (string): The unique identifier of the add-on.
- `configData` (object): New configuration settings.
- `serviceID` (string, optional): Filter by service ID.

**Returns:** `Promise<object>`.

##### `installAddon(addonID, serviceID = null)`

Installs an add-on by its ID.

**Parameters:**
- `addonID` (string): The unique identifier of the add-on.
- `serviceID` (string, optional): Filter by service ID.

**Returns:** `Promise<object>`.

##### `uninstallAddon(addonID, serviceID = null)`

Uninstalls an add-on by its ID.

**Parameters:**
- `addonID` (string): The unique identifier of the add-on.
- `serviceID` (string, optional): Filter by service ID.

**Returns:** `Promise<object>`.

##### `getAddonServices(language = null)`

Gets all available add-on services.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getAddonSuggestions(language = null)`

Gets a list of suggested add-ons for installation.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getAddonTypes(serviceID = null, language = null)`

Gets all available add-on types.

**Parameters:**
- `serviceID` (string, optional): Filter by service ID.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `installAddonFromUrl(url)`

Installs an add-on from a URL.

**Parameters:**
- `url` (string): The URL of the add-on to install.

**Returns:** `Promise<object>`.

Also available as `AsyncAddons`.

---

### Audio

Provides methods to interact with the openHAB audio system.

#### Constructor

```js
const audio = new Audio(client);
```

#### Methods

##### `getDefaultSink(language = null)`

Gets the default audio sink.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getDefaultSource(language = null)`

Gets the default audio source.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getSinks(language = null)`

Gets all available audio sinks.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getSources(language = null)`

Gets all available audio sources.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

Also available as `AsyncAudio`.

---

### Auth

Provides methods for authentication token and session management.

#### Constructor

```js
const auth = new Auth(client);
```

#### Methods

##### `getAPITokens()`

Gets all API tokens for the current user.

**Returns:** `Promise<object>`.

##### `revokeAPIToken(tokenName)`

Revokes a specific API token.

**Parameters:**
- `tokenName` (string): The name of the token to revoke.

**Returns:** `Promise<object>`.

##### `logout(refreshToken, sessionID)`

Terminates a session.

**Parameters:**
- `refreshToken` (string): The refresh token associated with the session.
- `sessionID` (string): The session ID.

**Returns:** `Promise<object>`.

##### `getSessions()`

Gets all active sessions for the current user.

**Returns:** `Promise<object>`.

##### `getToken({ useCookie = false, grantType = null, code = null, redirectURI = null, clientID = null, refreshToken = null, codeVerifier = null })`

Obtains access and refresh tokens. Parameters are passed as a destructured object.

**Parameters:**
- `useCookie` (boolean, optional): Use cookies for the session (default `false`).
- `grantType` (string, optional): The OAuth grant type.
- `code` (string, optional): Authorization code.
- `redirectURI` (string, optional): OAuth redirect URI.
- `clientID` (string, optional): OAuth client ID.
- `refreshToken` (string, optional): Refresh token for renewal.
- `codeVerifier` (string, optional): PKCE code verifier.

**Returns:** `Promise<object>`.

```js
const tokenData = await auth.getToken({ grantType: "password", clientID: "my-app" });
```

Also available as `AsyncAuth`.

---

### ChannelTypes

Provides methods to retrieve channel type information.

#### Constructor

```js
const channelTypes = new ChannelTypes(client);
```

#### Methods

##### `getChannelTypes(prefixes = null, language = null)`

Gets all available channel types.

**Parameters:**
- `prefixes` (string, optional): Filter by prefix.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getChannelType(channelTypeUID, language = null)`

Gets a specific channel type.

**Parameters:**
- `channelTypeUID` (string): The UID of the channel type.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getLinkableItemTypes(channelTypeUID)`

Gets item types that can be linked to a trigger channel type.

**Parameters:**
- `channelTypeUID` (string): The UID of the channel type.

**Returns:** `Promise<Array>`.

Also available as `AsyncChannelTypes`.

---

### ConfigDescriptions

Provides methods to retrieve configuration descriptions.

#### Constructor

```js
const configDescriptions = new ConfigDescriptions(client);
```

#### Methods

##### `getConfigDescriptions(scheme = null, language = null)`

Gets all configuration descriptions.

**Parameters:**
- `scheme` (string, optional): Filter by scheme.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getConfigDescription(uri, language = null)`

Gets a specific configuration description by URI.

**Parameters:**
- `uri` (string): The URI of the configuration description.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

Also available as `AsyncConfigDescriptions`.

---

### Discovery

Provides methods to interact with the openHAB discovery service.

#### Constructor

```js
const discovery = new Discovery(client);
```

#### Methods

##### `getDiscoveryBindings()`

Gets all bindings that support discovery.

**Returns:** `Promise<Array>` — list of binding IDs.

##### `getBindingInfo(bindingID, language = null)`

Gets information about a specific binding.

**Parameters:**
- `bindingID` (string): The ID of the binding.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `startBindingScan(bindingID, input = null)`

Starts the discovery process for a binding.

**Parameters:**
- `bindingID` (string): The ID of the binding.
- `input` (string, optional): Optional scan input.

**Returns:** `Promise<number>` — timeout duration in seconds.

```js
const timeout = await discovery.startBindingScan("zwave");
console.log("Scan timeout:", timeout, "seconds");
```

Also available as `AsyncDiscovery`.

---

### Events

Provides methods to subscribe to the openHAB event bus via SSE.

#### Constructor

```js
const events = new Events(client);
```

#### Methods

##### `getEvents(topics = null)`

Gets a stream of all openHAB events, optionally filtered by topic.

**Parameters:**
- `topics` (string, optional): Comma-separated list of topics to filter.

**Returns:** `Promise<Response>` — SSE stream.

##### `initiateStateTracker()`

Initiates a new state tracker connection.

**Returns:** `Promise<string>` — the SSE connection ID.

##### `updateSSEConnectionItems(connectionID, items)`

Updates the items tracked by an existing SSE connection.

**Parameters:**
- `connectionID` (string): The ID of the SSE connection.
- `items` (Array): List of item names to track.

**Returns:** `Promise<object|string>`.

Also available as `AsyncEvents`.

---

### ItemEvents

Provides SSE streams for item-related events.

#### Constructor

```js
const itemEvents = new ItemEvents(client);
```

#### Methods

##### `ItemEvent()`

Subscribes to all item events.

**Returns:** `Promise<Response>`.

##### `ItemAddedEvent(itemName = "*")`

Subscribes to item added events.

**Parameters:**
- `itemName` (string, optional): Filter by item name (default `"*"` for all).

**Returns:** `Promise<Response>`.

##### `ItemRemovedEvent(itemName = "*")`

Subscribes to item removed events.

##### `ItemUpdatedEvent(itemName = "*")`

Subscribes to item updated events.

##### `ItemCommandEvent(itemName = "*")`

Subscribes to item command events.

##### `ItemStateEvent(itemName = "*")`

Subscribes to item state events.

##### `ItemStatePredictedEvent(itemName = "*")`

Subscribes to item state predicted events.

##### `ItemStateChangedEvent(itemName = "*")`

Subscribes to item state changed events.

**Parameters:**
- `itemName` (string, optional): Filter by item name (default `"*"`).

**Returns:** `Promise<Response>` — SSE stream.

```js
const response = await itemEvents.ItemStateChangedEvent("MyLightSwitch");
const reader = response.body.getReader();
const decoder = new TextDecoder();

async function read() {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    const text = decoder.decode(value);
    for (const line of text.split("\n")) {
      if (line.startsWith("data: ")) {
        try { console.log(JSON.parse(line.slice(6))); } catch {}
      }
    }
  }
}
read();
```

##### `GroupItemStateChangedEvent(itemName, memberName)`

Subscribes to group item state changed events for a specific member.

**Parameters:**
- `itemName` (string): The name of the group item.
- `memberName` (string): The name of the member item.

**Returns:** `Promise<Response>`.

Also available as `AsyncItemEvents`.

---

### ThingEvents

Provides SSE streams for thing-related events.

#### Constructor

```js
const thingEvents = new ThingEvents(client);
```

#### Methods

##### `ThingAddedEvent(thingUID = "*")`

Subscribes to thing added events.

**Parameters:**
- `thingUID` (string, optional): Filter by thing UID (default `"*"`).

**Returns:** `Promise<Response>`.

##### `ThingRemovedEvent(thingUID = "*")`

Subscribes to thing removed events.

##### `ThingUpdatedEvent(thingUID = "*")`

Subscribes to thing updated events.

##### `ThingStatusInfoEvent(thingUID = "*")`

Subscribes to thing status info events.

##### `ThingStatusInfoChangedEvent(thingUID = "*")`

Subscribes to thing status info changed events.

Also available as `AsyncThingEvents`.

---

### InboxEvents

Provides SSE streams for inbox (discovery) events.

#### Constructor

```js
const inboxEvents = new InboxEvents(client);
```

#### Methods

##### `InboxAddedEvent(thingUID = "*")`

Subscribes to inbox added events.

##### `InboxRemovedEvent(thingUID = "*")`

Subscribes to inbox removed events.

##### `InboxUpdatedEvent(thingUID = "*")`

Subscribes to inbox updated events.

All methods accept an optional `thingUID` filter (default `"*"`).

Also available as `AsyncInboxEvents`.

---

### LinkEvents

Provides SSE streams for item-channel link events.

#### Methods

##### `ItemChannelLinkAddedEvent(itemName = "*", channelUID = "*")`

Subscribes to link added events.

**Parameters:**
- `itemName` (string, optional): Filter by item name (default `"*"`).
- `channelUID` (string, optional): Filter by channel UID (default `"*"`).

**Returns:** `Promise<Response>`.

##### `ItemChannelLinkRemovedEvent(itemName = "*", channelUID = "*")`

Subscribes to link removed events.

Also available as `AsyncLinkEvents`.

---

### ChannelEvents

Provides SSE streams for channel events.

#### Methods

##### `ChannelDescriptionChangedEvent(channelUID = "*")`

Subscribes to channel description changed events.

**Parameters:**
- `channelUID` (string, optional): Filter by channel UID (default `"*"`).

**Returns:** `Promise<Response>`.

##### `ChannelTriggeredEvent(channelUID = "*")`

Subscribes to channel triggered events.

Also available as `AsyncChannelEvents`.

---

### Iconsets

Provides methods to retrieve available iconsets.

#### Methods

##### `getIconsets(language = null)`

Gets all available iconsets.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

Also available as `AsyncIconsets`.

---

### Inbox

Provides methods to manage the openHAB inbox (discovery results).

#### Constructor

```js
const inbox = new Inbox(client);
```

#### Methods

##### `getDiscoveredThings(includeIgnored = true)`

Gets all discovered things.

**Parameters:**
- `includeIgnored` (boolean, optional): Include ignored results (default `true`).

**Returns:** `Promise<Array>`.

##### `removeDiscoveryResult(thingUID)`

Removes a discovery result.

**Parameters:**
- `thingUID` (string): The UID of the thing to remove.

**Returns:** `Promise<object>`.

##### `approveDiscoveryResult(thingUID, thingLabel, newThingID = null, language = null)`

Approves a discovery result and creates the thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `thingLabel` (string): The label for the new thing.
- `newThingID` (string, optional): Optional new thing ID.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `ignoreDiscoveryResult(thingUID)`

Marks a discovery result as ignored.

**Parameters:**
- `thingUID` (string): The UID of the thing to ignore.

**Returns:** `Promise<object>`.

##### `unignoreDiscoveryResult(thingUID)`

Removes the ignore flag from a discovery result.

**Parameters:**
- `thingUID` (string): The UID of the thing to unignore.

**Returns:** `Promise<object>`.

Also available as `AsyncInbox`.

---

### Items

Provides methods to manage openHAB items.

#### Constructor

```js
const { OpenHABClient, Items } = openHAB;
const client = new OpenHABClient("http://127.0.0.1:8080", "openhab", "habopen");
const itemsAPI = new Items(client);
```

#### Methods

##### `getItems({ type, tags, metadata, recursive, fields, staticDataOnly, language } = {})`

Gets all available items. Parameters are passed as a destructured object.

**Parameters:**
- `type` (string, optional): Item type filter.
- `tags` (string, optional): Item tag filter.
- `metadata` (string, optional): Metadata selector (default `".*"`).
- `recursive` (boolean, optional): Fetch group members recursively (default `false`).
- `fields` (string, optional): Comma-separated list of fields to return.
- `staticDataOnly` (boolean, optional): Return only cached data (default `false`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

```js
const items = await itemsAPI.getItems({ type: "Switch", recursive: true });
```

##### `addOrUpdateItems(items)`

Adds or updates a list of items.

**Parameters:**
- `items` (Array): List of item data objects.

**Returns:** `Promise<object>`.

##### `getItem(itemName, { metadata, recursive, language } = {})`

Gets a single item. Options are passed as a destructured object.

**Parameters:**
- `itemName` (string): The name of the item.
- `metadata` (string, optional): Metadata selector (default `".*"`).
- `recursive` (boolean, optional): Fetch group members recursively (default `true`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

```js
const item = await itemsAPI.getItem("MyLightSwitch");
```

##### `addOrUpdateItem(itemName, itemData, language = null)`

Adds or updates a single item.

**Parameters:**
- `itemName` (string): The name of the item.
- `itemData` (object): The item data.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `sendCommand(itemName, command)`

Sends a command to an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `command` (string): The command to send (e.g. `"ON"`, `"OFF"`, `"50"`).

**Returns:** `Promise<object>`.

```js
await itemsAPI.sendCommand("MyLightSwitch", "ON");
```

##### `postUpdate(itemName, state)`

Updates the state of an item. Alias for `updateItemState`.

**Parameters:**
- `itemName` (string): The name of the item.
- `state` (string): The new state.

**Returns:** `Promise<object>`.

##### `deleteItem(itemName)`

Removes an item from the registry.

**Parameters:**
- `itemName` (string): The name of the item.

**Returns:** `Promise<object>`.

##### `addGroupMember(itemName, memberItemName)`

Adds a member to a group item.

**Parameters:**
- `itemName` (string): The name of the group item.
- `memberItemName` (string): The name of the member item.

**Returns:** `Promise<object>`.

##### `removeGroupMember(itemName, memberItemName)`

Removes a member from a group item.

**Parameters:**
- `itemName` (string): The name of the group item.
- `memberItemName` (string): The name of the member item.

**Returns:** `Promise<object>`.

##### `addMetadata(itemName, namespace, metadata)`

Adds metadata to an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `namespace` (string): The metadata namespace.
- `metadata` (object): The metadata to add.

**Returns:** `Promise<object>`.

##### `removeMetadata(itemName, namespace)`

Removes metadata from an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `namespace` (string): The metadata namespace to remove.

**Returns:** `Promise<object>`.

##### `getMetadataNamespaces(itemName, language = null)`

Gets all metadata namespaces of an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getSemanticItem(itemName, semanticClass, language = null)`

Gets the item that defines the requested semantics.

**Parameters:**
- `itemName` (string): The name of the item.
- `semanticClass` (string): The requested semantic class.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getItemState(itemName)`

Gets the state of an item.

**Parameters:**
- `itemName` (string): The name of the item.

**Returns:** `Promise<string>` — the current state as plain text.

```js
const state = await itemsAPI.getItemState("MyLightSwitch");
console.log(state); // "ON"
```

##### `updateItemState(itemName, state, language = null)`

Updates the state of an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `state` (string): The new state.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `addTag(itemName, tag)`

Adds a tag to an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `tag` (string): The tag to add.

**Returns:** `Promise<object>`.

##### `removeTag(itemName, tag)`

Removes a tag from an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `tag` (string): The tag to remove.

**Returns:** `Promise<object>`.

##### `purgeOrphanedMetadata()`

Removes unused/orphaned metadata from all items.

**Returns:** `Promise<object>`.

Also available as `AsyncItems`.

---

### Links

Provides methods to manage item-channel links.

#### Constructor

```js
const links = new Links(client);
```

#### Methods

##### `getLinks(channelUID = null, itemName = null)`

Gets all links, optionally filtered.

**Parameters:**
- `channelUID` (string, optional): Filter by channel UID.
- `itemName` (string, optional): Filter by item name.

**Returns:** `Promise<Array>`.

##### `getLink(itemName, channelUID)`

Gets a specific link between an item and a channel.

**Parameters:**
- `itemName` (string): The name of the item.
- `channelUID` (string): The UID of the channel.

**Returns:** `Promise<object>`.

##### `linkItemToChannel(itemName, channelUID, configuration)`

Links an item to a channel.

**Parameters:**
- `itemName` (string): The name of the item.
- `channelUID` (string): The UID of the channel.
- `configuration` (object): The link configuration.

**Returns:** `Promise<object>`.

##### `unlinkItemFromChannel(itemName, channelUID)`

Unlinks an item from a channel.

**Parameters:**
- `itemName` (string): The name of the item.
- `channelUID` (string): The UID of the channel.

**Returns:** `Promise<object>`.

##### `deleteAllLinks(object)`

Deletes all links for an item or thing.

**Parameters:**
- `object` (string): The item name or thing UID.

**Returns:** `Promise<object>`.

##### `getOrphanLinks()`

Gets all orphan links (links to non-existent channels).

**Returns:** `Promise<Array>`.

##### `purgeUnusedLinks()`

Removes all unused/orphaned links.

**Returns:** `Promise<object>`.

Also available as `AsyncLinks`.

---

### Logging

Provides methods to manage openHAB loggers.

#### Constructor

```js
const logging = new Logging(client);
```

#### Methods

##### `getLoggers()`

Gets all loggers and their levels.

**Returns:** `Promise<object>`.

##### `getLogger(loggerName)`

Gets a specific logger.

**Parameters:**
- `loggerName` (string): The name of the logger.

**Returns:** `Promise<object>`.

##### `modifyOrAddLogger(loggerName, level)`

Modifies an existing logger or adds a new one.

**Parameters:**
- `loggerName` (string): The name of the logger.
- `level` (string): The log level (`"DEBUG"`, `"INFO"`, `"WARN"`, `"ERROR"`).

**Returns:** `Promise<object>`.

##### `removeLogger(loggerName)`

Removes a logger.

**Parameters:**
- `loggerName` (string): The name of the logger to remove.

**Returns:** `Promise<object>`.

Also available as `AsyncLogging`.

---

### ModuleTypes

Provides methods to retrieve rule module types.

#### Constructor

```js
const moduleTypes = new ModuleTypes(client);
```

#### Methods

##### `getModuleTypes(tags = null, typeFilter = null, language = null)`

Gets all available module types.

**Parameters:**
- `tags` (string, optional): Filter by tags.
- `typeFilter` (string, optional): Filter by type (`"trigger"`, `"condition"`, `"action"`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getModuleType(moduleTypeUID, language = null)`

Gets a specific module type.

**Parameters:**
- `moduleTypeUID` (string): The UID of the module type.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

Also available as `AsyncModuleTypes`.

---

### Persistence

Provides methods to interact with openHAB persistence services.

#### Constructor

```js
const persistence = new Persistence(client);
```

#### Methods

##### `getServices(language = null)`

Gets all persistence services.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getServiceConfiguration(serviceID)`

Gets the configuration of a persistence service.

**Parameters:**
- `serviceID` (string): The ID of the persistence service.

**Returns:** `Promise<object>`.

##### `setServiceConfiguration(serviceID, config)`

Sets the configuration of a persistence service.

**Parameters:**
- `serviceID` (string): The ID of the persistence service.
- `config` (object): The configuration data.

**Returns:** `Promise<object>`.

##### `deleteServiceConfiguration(serviceID)`

Deletes the configuration of a persistence service.

**Parameters:**
- `serviceID` (string): The ID of the persistence service.

**Returns:** `Promise<object>`.

##### `getItemsFromService(serviceID = null)`

Gets all items available via a persistence service.

**Parameters:**
- `serviceID` (string, optional): The ID of the persistence service.

**Returns:** `Promise<Array>`.

##### `getItemPersistenceData(itemName, serviceID, startTime = null, endTime = null, page = 1, pageLength = 50, boundary = false, itemState = false)`

Gets item persistence data for a time range.

**Parameters:**
- `itemName` (string): The name of the item.
- `serviceID` (string): The ID of the persistence service.
- `startTime` (string, optional): Start timestamp.
- `endTime` (string, optional): End timestamp.
- `page` (number, optional): Page number (default `1`).
- `pageLength` (number, optional): Items per page (default `50`).
- `boundary` (boolean, optional): Include boundary values (default `false`).
- `itemState` (boolean, optional): Return item state instead of raw value (default `false`).

**Returns:** `Promise<object>`.

```js
const data = await persistence.getItemPersistenceData(
  "MyTemperatureSensor",
  "rrd4j",
  "2024-01-01T00:00:00.000+0000",
  "2024-01-02T00:00:00.000+0000"
);
```

##### `storeItemData(itemName, time, state, serviceID = null)`

Stores a data point for an item.

**Parameters:**
- `itemName` (string): The name of the item.
- `time` (string): The timestamp for the data point.
- `state` (string): The state value to store.
- `serviceID` (string, optional): The ID of the persistence service.

**Returns:** `Promise<object>`.

##### `deleteItemData(itemName, startTime, endTime, serviceID)`

Deletes item data within a time range.

**Parameters:**
- `itemName` (string): The name of the item.
- `startTime` (string): Start timestamp.
- `endTime` (string): End timestamp.
- `serviceID` (string): The ID of the persistence service.

**Returns:** `Promise<object>`.

Also available as `AsyncPersistence`.

---

### ProfileTypes

Provides methods to retrieve profile types.

#### Constructor

```js
const profileTypes = new ProfileTypes(client);
```

#### Methods

##### `getProfileTypes(channelTypeUID = null, itemType = null, language = null)`

Gets all available profile types.

**Parameters:**
- `channelTypeUID` (string, optional): Filter by channel type UID.
- `itemType` (string, optional): Filter by item type.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

Also available as `AsyncProfileTypes`.

---

### Rules

Provides methods to manage openHAB rules.

#### Constructor

```js
const rules = new Rules(client);
```

#### Methods

##### `getRules(prefix = null, tags = null, summary = false, staticDataOnly = false)`

Gets all rules.

**Parameters:**
- `prefix` (string, optional): Filter by rule UID prefix.
- `tags` (string, optional): Filter by tags.
- `summary` (boolean, optional): Return summary only (default `false`).
- `staticDataOnly` (boolean, optional): Return only cached data (default `false`).

**Returns:** `Promise<Array>`.

##### `createRule(ruleData)`

Creates a new rule.

**Parameters:**
- `ruleData` (object): The rule configuration.

**Returns:** `Promise<object>`.

##### `getRule(ruleUID)`

Gets a specific rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.

**Returns:** `Promise<object>`.

##### `updateRule(ruleUID, ruleData)`

Updates an existing rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `ruleData` (object): The updated rule data.

**Returns:** `Promise<object>`.

##### `deleteRule(ruleUID)`

Deletes a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.

**Returns:** `Promise<object>`.

##### `getModule(ruleUID, moduleCategory, moduleID)`

Gets a specific module of a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `moduleCategory` (string): The module category (`"triggers"`, `"conditions"`, `"actions"`).
- `moduleID` (string): The ID of the module.

**Returns:** `Promise<object>`.

##### `getModuleConfig(ruleUID, moduleCategory, moduleID)`

Gets the configuration of a module.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `moduleCategory` (string): The module category.
- `moduleID` (string): The module ID.

**Returns:** `Promise<object>`.

##### `getModuleConfigParam(ruleUID, moduleCategory, moduleID, param)`

Gets a specific configuration parameter of a module.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `moduleCategory` (string): The module category.
- `moduleID` (string): The module ID.
- `param` (string): The parameter name.

**Returns:** `Promise<string>`.

##### `setModuleConfigParam(ruleUID, moduleCategory, moduleID, param, value)`

Sets a configuration parameter of a module.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `moduleCategory` (string): The module category.
- `moduleID` (string): The module ID.
- `param` (string): The parameter name.
- `value` (string): The new value.

**Returns:** `Promise<object>`.

##### `getActions(ruleUID)`

Gets all action modules of a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.

**Returns:** `Promise<Array>`.

##### `getConditions(ruleUID)`

Gets all condition modules of a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.

**Returns:** `Promise<Array>`.

##### `getTriggers(ruleUID)`

Gets all trigger modules of a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.

**Returns:** `Promise<Array>`.

##### `getConfiguration(ruleUID)`

Gets the configuration of a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.

**Returns:** `Promise<object>`.

##### `updateConfiguration(ruleUID, configData)`

Updates the configuration of a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `configData` (object): The new configuration.

**Returns:** `Promise<object>`.

##### `setRuleState(ruleUID, enable)`

Enables or disables a rule.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `enable` (boolean): `true` to enable, `false` to disable.

**Returns:** `Promise<object>`.

##### `enable(ruleUID)`

Enables a rule. Convenience wrapper for `setRuleState(ruleUID, true)`.

**Returns:** `Promise<object>`.

##### `disable(ruleUID)`

Disables a rule. Convenience wrapper for `setRuleState(ruleUID, false)`.

**Returns:** `Promise<object>`.

##### `runNow(ruleUID, contextData = null)`

Executes a rule immediately.

**Parameters:**
- `ruleUID` (string): The UID of the rule.
- `contextData` (object, optional): Context data for the execution.

**Returns:** `Promise<object>`.

##### `simulateSchedule(fromTime, untilTime)`

Simulates the rule schedule between two timestamps.

**Parameters:**
- `fromTime` (string): The start timestamp.
- `untilTime` (string): The end timestamp.

**Returns:** `Promise<object>`.

Also available as `AsyncRules`.

---

### Services

Provides methods to manage openHAB configurable services.

#### Constructor

```js
const services = new Services(client);
```

#### Methods

##### `getServices(language = null)`

Gets all configurable services.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getService(serviceID, language = null)`

Gets a specific service by ID.

**Parameters:**
- `serviceID` (string): The ID of the service.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getServiceConfig(serviceID)`

Gets the configuration of a service.

**Parameters:**
- `serviceID` (string): The ID of the service.

**Returns:** `Promise<object>`.

##### `updateServiceConfig(serviceID, configData, language = null)`

Updates the configuration of a service.

**Parameters:**
- `serviceID` (string): The ID of the service.
- `configData` (object): The new configuration.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `deleteServiceConfig(serviceID)`

Deletes the configuration of a service.

**Parameters:**
- `serviceID` (string): The ID of the service.

**Returns:** `Promise<object>`.

##### `getServiceContexts(serviceID, language = null)`

Gets all contexts of a multi-context service.

**Parameters:**
- `serviceID` (string): The ID of the service.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

Also available as `AsyncServices`.

---

### Sitemaps

Provides methods to interact with openHAB sitemaps.

#### Constructor

```js
const sitemaps = new Sitemaps(client);
```

#### Methods

##### `getSitemaps()`

Gets all available sitemaps.

**Returns:** `Promise<Array>`.

##### `getSitemap(sitemapName, type = null, jsonCallback = null, includeHidden = false, language = null)`

Gets a specific sitemap.

**Parameters:**
- `sitemapName` (string): The name of the sitemap.
- `type` (string, optional): The subscription type.
- `jsonCallback` (string, optional): JSONP callback name.
- `includeHidden` (boolean, optional): Include hidden widgets (default `false`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getSitemapPage(sitemapName, pageID, subscriptionID = null, includeHidden = false, language = null)`

Gets a specific page of a sitemap.

**Parameters:**
- `sitemapName` (string): The name of the sitemap.
- `pageID` (string): The ID of the page.
- `subscriptionID` (string, optional): Subscription ID for real-time updates.
- `includeHidden` (boolean, optional): Include hidden widgets (default `false`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getFullSitemap(sitemapName, subscriptionID = null, includeHidden = false, language = null)`

Gets the full sitemap including all pages.

**Parameters:**
- `sitemapName` (string): The name of the sitemap.
- `subscriptionID` (string, optional): Subscription ID for real-time updates.
- `includeHidden` (boolean, optional): Include hidden widgets (default `false`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getSitemapEvents(subscriptionID, sitemapName = null, pageID = null)`

Gets sitemap events for a subscription.

**Parameters:**
- `subscriptionID` (string): The subscription ID.
- `sitemapName` (string, optional): Filter by sitemap name.
- `pageID` (string, optional): Filter by page ID.

**Returns:** `Promise<Response>` — SSE stream.

##### `getFullSitemapEvents(subscriptionID, sitemapName = null)`

Gets full sitemap events for a subscription.

**Parameters:**
- `subscriptionID` (string): The subscription ID.
- `sitemapName` (string, optional): Filter by sitemap name.

**Returns:** `Promise<Response>` — SSE stream.

##### `subscribeToSitemapEvents()`

Creates a new subscription for sitemap events.

**Returns:** `Promise<object>` — contains the subscription ID.

Also available as `AsyncSitemaps`.

---

### Systeminfo

Provides methods to retrieve openHAB system information.

#### Constructor

```js
const systeminfo = new Systeminfo(client);
```

#### Methods

##### `getSystemInfo()`

Gets general system information.

**Returns:** `Promise<object>`.

##### `getUoMInfo()`

Gets units of measurement information.

**Returns:** `Promise<object>`.

Also available as `AsyncSysteminfo`.

---

### Tags

Provides methods to manage openHAB semantic tags.

#### Constructor

```js
const tags = new Tags(client);
```

#### Methods

##### `getTags(language = null)`

Gets all available semantic tags.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `createTag(tagData, language = null)`

Creates a new semantic tag.

**Parameters:**
- `tagData` (object): The tag data.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getTag(tagID, language = null)`

Gets a specific semantic tag.

**Parameters:**
- `tagID` (string): The ID of the tag.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `updateTag(tagID, tagData, language = null)`

Updates a semantic tag.

**Parameters:**
- `tagID` (string): The ID of the tag.
- `tagData` (object): The new tag data.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `deleteTag(tagID, language = null)`

Deletes a semantic tag.

**Parameters:**
- `tagID` (string): The ID of the tag.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

Also available as `AsyncTags`.

---

### Templates

Provides methods to retrieve rule templates.

#### Constructor

```js
const templates = new Templates(client);
```

#### Methods

##### `getTemplates(language = null)`

Gets all available rule templates.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getTemplate(templateUID, language = null)`

Gets a specific rule template.

**Parameters:**
- `templateUID` (string): The UID of the template.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

Also available as `AsyncTemplates`.

---

### ThingTypes

Provides methods to retrieve thing types.

#### Constructor

```js
const thingTypes = new ThingTypes(client);
```

#### Methods

##### `getThingTypes(bindingID = null, language = null)`

Gets all available thing types.

**Parameters:**
- `bindingID` (string, optional): Filter by binding ID.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getThingType(thingTypeUID, language = null)`

Gets a specific thing type.

**Parameters:**
- `thingTypeUID` (string): The UID of the thing type.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

Also available as `AsyncThingTypes`.

---

### Things

Provides methods to manage openHAB things.

#### Constructor

```js
const things = new Things(client);
```

#### Methods

##### `getThings(summary = false, staticDataOnly = false, language = null)`

Gets all things.

**Parameters:**
- `summary` (boolean, optional): Return summary only (default `false`).
- `staticDataOnly` (boolean, optional): Return only cached data (default `false`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `createThing(thingData, language = null)`

Creates a new thing.

**Parameters:**
- `thingData` (object): The thing configuration.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getThing(thingUID, language = null)`

Gets a specific thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `updateThing(thingUID, thingData, language = null)`

Updates a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `thingData` (object): The updated thing data.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `deleteThing(thingUID, force = false, language = null)`

Deletes a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `force` (boolean, optional): Force deletion even if linked (default `false`).
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `updateThingConfiguration(thingUID, configurationData, language = null)`

Updates the configuration of a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `configurationData` (object): The new configuration.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getThingConfigStatus(thingUID, language = null)`

Gets the configuration status of a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `setThingStatus(thingUID, enabled, language = null)`

Enables or disables a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `enabled` (boolean): `true` to enable, `false` to disable.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `enableThing(thingUID)`

Enables a thing. Convenience wrapper for `setThingStatus(thingUID, true)`.

**Returns:** `Promise<object>`.

##### `disableThing(thingUID)`

Disables a thing. Convenience wrapper for `setThingStatus(thingUID, false)`.

**Returns:** `Promise<object>`.

##### `updateThingFirmware(thingUID, firmwareVersion, language = null)`

Updates the firmware of a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `firmwareVersion` (string): The firmware version to install.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getThingFirmwareStatus(thingUID, language = null)`

Gets the firmware update status of a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `getThingFirmwares(thingUID, language = null)`

Gets all available firmware versions for a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getThingStatus(thingUID, language = null)`

Gets the status of a thing.

**Parameters:**
- `thingUID` (string): The UID of the thing.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

Also available as `AsyncThings`.

---

### Transformations

Provides methods to manage openHAB transformations.

#### Constructor

```js
const transformations = new Transformations(client);
```

#### Methods

##### `getTransformations()`

Gets all transformations.

**Returns:** `Promise<Array>`.

##### `getTransformation(transformationUID)`

Gets a specific transformation.

**Parameters:**
- `transformationUID` (string): The UID of the transformation.

**Returns:** `Promise<object>`.

##### `updateTransformation(transformationUID, transformationData)`

Updates a transformation.

**Parameters:**
- `transformationUID` (string): The UID of the transformation.
- `transformationData` (any): The new transformation data.

**Returns:** `Promise<object>`.

##### `deleteTransformation(transformationUID)`

Deletes a transformation.

**Parameters:**
- `transformationUID` (string): The UID of the transformation.

**Returns:** `Promise<object>`.

##### `getTransformationServices()`

Gets all available transformation services.

**Returns:** `Promise<Array>`.

Also available as `AsyncTransformations`.

---

### UI

Provides methods to manage UI components and tiles.

#### Constructor

```js
const ui = new UI(client);
```

#### Methods

##### `getUIComponents(namespace, summary = false)`

Gets all UI components in a namespace.

**Parameters:**
- `namespace` (string): The namespace.
- `summary` (boolean, optional): Return summary only (default `false`).

**Returns:** `Promise<Array>`.

##### `addUIComponent(namespace, componentData)`

Adds a UI component to a namespace.

**Parameters:**
- `namespace` (string): The namespace.
- `componentData` (object): The component data.

**Returns:** `Promise<object>`.

##### `getUIComponent(namespace, componentUID)`

Gets a specific UI component.

**Parameters:**
- `namespace` (string): The namespace.
- `componentUID` (string): The UID of the component.

**Returns:** `Promise<object>`.

##### `updateUIComponent(namespace, componentUID, componentData)`

Updates a UI component.

**Parameters:**
- `namespace` (string): The namespace.
- `componentUID` (string): The UID of the component.
- `componentData` (object): The new component data.

**Returns:** `Promise<object>`.

##### `deleteUIComponent(namespace, componentUID)`

Deletes a UI component.

**Parameters:**
- `namespace` (string): The namespace.
- `componentUID` (string): The UID of the component.

**Returns:** `Promise<object>`.

##### `getUITiles()`

Gets all registered UI tiles.

**Returns:** `Promise<Array>`.

Also available as `AsyncUI`.

---

### UUID

Provides a method to retrieve the openHAB instance UUID.

#### Constructor

```js
const uuid = new UUID(client);
```

#### Methods

##### `getUUID()`

Gets the UUID of the openHAB instance.

**Returns:** `Promise<string>`.

```js
const id = await uuid.getUUID();
console.log(id);
```

Also available as `AsyncUUID`.

---

### Voice

Provides methods to interact with the openHAB voice system.

#### Constructor

```js
const voice = new Voice(client);
```

#### Methods

##### `getDefaultVoice()`

Gets the default voice.

**Returns:** `Promise<object>`.

##### `getVoices()`

Gets all available voices.

**Returns:** `Promise<Array>`.

##### `getInterpreters(language = null)`

Gets all available human language interpreters.

**Parameters:**
- `language` (string, optional): Language for the response.

**Returns:** `Promise<Array>`.

##### `getInterpreter(interpreterID, language = null)`

Gets a specific interpreter.

**Parameters:**
- `interpreterID` (string): The ID of the interpreter.
- `language` (string, optional): Language for the response.

**Returns:** `Promise<object>`.

##### `interpretText(text, language = null)`

Sends text to the default interpreter.

**Parameters:**
- `text` (string): The text to interpret.
- `language` (string, optional): The language of the text.

**Returns:** `Promise<object>`.

##### `interpretTextBatch(text, IDs, language = null)`

Sends text to multiple interpreters.

**Parameters:**
- `text` (string): The text to interpret.
- `IDs` (Array): List of interpreter IDs.
- `language` (string, optional): The language of the text.

**Returns:** `Promise<object>`.

##### `startDialog(sourceID, { ksID, sttID, ttsID, voiceID, hliIDs, sinkID, keyword, listeningItem } = {})`

Starts dialog processing for an audio source. Options are passed as a destructured object.

**Parameters:**
- `sourceID` (string): The ID of the audio source.
- `ksID` (string, optional): Keyword spotter ID.
- `sttID` (string, optional): Speech-to-text ID.
- `ttsID` (string, optional): Text-to-speech ID.
- `voiceID` (string, optional): Voice ID.
- `hliIDs` (string, optional): Comma-separated list of interpreter IDs.
- `sinkID` (string, optional): Audio output ID.
- `keyword` (string, optional): Keyword to start the dialog.
- `listeningItem` (string, optional): Item name to listen to.

**Returns:** `Promise<object>`.

```js
await voice.startDialog("javasound:source:microphone", {
  sttID: "googlestt",
  ttsID: "googletts",
  voiceID: "google:en-US:en-US-Wavenet-A"
});
```

##### `stopDialog(sourceID)`

Stops dialog processing.

**Parameters:**
- `sourceID` (string): The ID of the audio source.

**Returns:** `Promise<object>`.

##### `listenAndAnswer(sourceID, sttID, ttsID, voiceID, hliIDs = null, sinkID = null, listeningItem = null)`

Executes a single listen-and-answer dialog without keyword spotting.

**Parameters:**
- `sourceID` (string): The ID of the audio source.
- `sttID` (string): The speech-to-text ID.
- `ttsID` (string): The text-to-speech ID.
- `voiceID` (string): The voice ID.
- `hliIDs` (Array, optional): List of interpreter IDs.
- `sinkID` (string, optional): Audio output ID.
- `listeningItem` (string, optional): Item name to listen to.

**Returns:** `Promise<object>`.

##### `sayText(text, voiceID, sinkID, volume = "100")`

Speaks text aloud.

**Parameters:**
- `text` (string): The text to speak.
- `voiceID` (string): The ID of the voice.
- `sinkID` (string): The ID of the audio output.
- `volume` (string, optional): Volume level (default `"100"`).

**Returns:** `Promise<object>`.

```js
await voice.sayText("Hello from openHAB!", "voicerss:en-us", "javasound:sink:default");
```

Also available as `AsyncVoice`.

---

## JavaScript vs. Python — Key Differences

| Topic | Python | JavaScript |
|---|---|---|
| Client | `OpenHABClient` (sync `requests`) | `OpenHABClient` (all methods return `Promise`) |
| Async client | `AsyncOpenHABClient` (`aiohttp`, `async with`) | `AsyncOpenHABClient` (identical to sync) |
| Usage | `itemsAPI.getItems()` | `await itemsAPI.getItems()` |
| SSE streams | `response.iter_lines()` | `response.body.getReader()` |
| Named parameters | `getItems(type="Switch")` | `getItems({ type: "Switch" })` |
| Module access | `from openhab import Items` | `const { Items } = openHAB` |
| Install | `pip install python-openhab-rest-client` | `<script src="...openhab.js">` |

---

## Contributing

Contributions are welcome! Please create an issue or pull request to suggest changes.

### How to contribute:
1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your feature description"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a pull request.

Please ensure your code follows the existing style and includes relevant documentation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
