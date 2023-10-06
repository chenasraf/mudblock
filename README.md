# ![Logo](/assets/images/logo/logo.png) Mudblock

This is a MUD ([Multi User Dungeon](https://en.wikipedia.org/wiki/Multi-user_dungeon)) client,
designed to be cross platform for both mobile and desktop.

Mudblock supports scripting via Lua, with portable files, which you can tie all together using
aliases, triggers and other familiar MUD client features.

<details>

<summary>Screenshots</summary>
<h3>Android</h3>

![android screenshot 1](/assets/images/docs/sc001.png)
![android screenshot 2](/assets/images/docs/sc002.png)
![android screenshot 3](/assets/images/docs/sc003.png)

</details>

## Features

- Multiple profiles
- Customizable on-screen buttons
- Triggers
- Aliases
- Supports scripting (Lua) that aims to be compatible with MUSHclient
- Profiles are portable & sharing content is easy

### Planned features

- Background app keepalive
- Timers
- MUSHclient plugin compatibility

### Supported platforms

Tested:

- Android
- macOS

Not tested:

- Windows
- Linux
- iOS

## Development

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
1. Clone this repo
1. Copy `lib/core/secrets.example.dart` to `lib/core/secrets.dart`, and make the modifications as
   specified in the file comments. The secrets are ignored on git for security reasons for users of
   this app via official channels.
1. Run `flutter run` to start developing on an emulator or a connected device

> This app is in early development stages and things are very likely to change and break with
> updates.

## Contributing

I am developing this package on my free time, so any support, whether code, issues, or just stars is
very helpful to sustaining its life. If you are feeling incredibly generous and would like to donate
just a small amount to help sustain this project, I would be very very thankful!

<a href='https://ko-fi.com/casraf' target='_blank'>
  <img height='36' style='border:0px;height:36px;'
    src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
    alt='Buy Me a Coffee at ko-fi.com' />
</a>

I welcome any issues or pull requests on GitHub. If you find a bug, or would like a new feature,
don't hesitate to open an appropriate issue and I will do my best to reply promptly.
