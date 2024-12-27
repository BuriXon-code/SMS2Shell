# SMS2Shell

## About ...

SMS2Shell is an extended Bash script dedicated to Termux that executes specific shell commands received via SMS.

It can be useful, for example, when a device is lost (to obtain its location), when using the device as an http server, and many others.

The script doesn't use any magic! It's all just bash, termux-api and decorations like jq, curl etc.

SMS2Shell, when launched, scans the list of recently received SMS every few seconds, looking for messages containing the prompt `>>`. After finding the appropriate message, it parses its content along with the message _id and the sender's number, executes the command, saves _id in the cache so as not to repeat the command from the same message by mistake, and then sends the sender an SMS with information about the command status.

![screenshot](/img.jpg)

## Installation ...

To install the script, perform:

```
git clone https://github.com/BuriXon-code/SMS2Shell
cd SMS2Shell
chmod +x SMS2Shell
```

## Usage ...

### Simple start-up:
```
./SMS2Shell
```
or run in background:
```
./SMS2Shell &
```
> [!NOTE]
> The script does not require any parameters.

### Other launch options:
+ Starting via tmux or crone.
+ Starting via bash/zsh/fish config file.
> [!NOTE]
> The script cannot be run via **login** command in Termux because **login** occurs before bash is started.

> [!TIP]
> I personally use a script on Termux startup, running it in ZSH. I can help implement automatic startup. Contact me: **sms2shell@burixon.com.pl**

### Available commands:

+ `>> BATTERY` [sends the sender the current parameters of the device's battery]
+ `>> TORCH <ON/OFF>` [turns on or off the device's flashlight]
+ `>> UPTIME` [sends back information about the device's operating time to the sender]
+ `>> LOCATION` [returns the current geographic coordinates of the device to the sender]
+ `>> WHOAMI` [returns the sender Termux's android username (e.g. u0_a703)]
+ `>> TEXT <text>` [sends the entered text back to the sender]
+ `>> CALC <operation>` [performs the given mathematical operation and returns it to the sender]
+ `>> APACHE <ON/OFF>` [turns on or off the http apache2 server]
+ `>> VOLUME NOTIFICATION <value 0-15>` [sets the volume level]
+ `>> VOLUME MUSIC <value 0-150>` [sets the volume level]
+ `>> VOLUME RING <value 0-15>` [sets the volume level]
+ `>> KILL` [kills the main Termux/terminal process]
+ `>> KILL-SELF` [kills its own PID]

![screenshot](/sms.jpg)

## Compatibility ...

The script for proper operation requires installed and configured Termux:API together with the termux-api package, Bash package installed.

It was tested in Termux 0.119-beta with Polish phone numbers.

> [!CAUTION]
> **In the event of significant abuse in terms of the count and content of sent SMS messages, the operator may block the user's SIM card.**

> [!TIP]
> Use wisely! :\)

In case of errors/problems with the script, let me know: **support@burixon.com.pl**.
