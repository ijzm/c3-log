> [!WARNING]
> The library is still in development

# C3-log
Simple logging library for the [C3 Language](https://github.com/c3lang/c3c)

# ⚡ Quick Start
```console
$ c3c run
```

# 🚧 TODO:
1. Make Styles Customizable
2. ~~Set style Format~~
3. Allow Bold/Underline/Italics, etc
4. ~~Allow More Variables (Time, etc)~~
5. Bundle as a library
6. Make Documentation
6. Testing

Inspiration from: https://docs.python.org/3/library/logging.html

# 📄 Usage

By default, just call any of the log functions:

```c++
import log;

fn void main() {
	log::debug("Hello World!");
}
```

## Logging Levels
Currently there are 7 log levels supported, in order:

Level | Function                              |
------|---------------------------------------|
TRACE | `log::trace(String format, args...);` | 
DEBUG | `log::debug(String format, args...);` | 
INFO  | `log::info(String format, args...);`  | 
NOTIF | `log::notif(String format, args...);` | 
WARN  | `log::warn(String format, args...);`  | 
ERROR | `log::error(String format, args...);` | 
FATAL | `log::fatal(String format, args...);` | 

You can set the current logging level with `log::set_level(Log_Level level)`

```c++
log::set_level(Log_Level.INFO);
log::debug("This message won't be shown!");
log::info("This message will be shown!");
```

## Formatting

The following format specifications are supported:

Format     | Description                                | 
-----------|--------------------------------------------| 
NONE       | None                                       | 
MESSAGE    |                                            | 
COLOR      | Color Style                                | 
BACKGROUND | Background Color Style                     | 
LEVEL      | Current Level (DEBUG, INFO, ERROR, etc...) | 
FILE       | Current file path (relative)               | 
LINE       | Current line                               | 
FUNC       | Current Function                           | 
ISO8601    | Datetime in YYYY-MM-DD hh:mm:ss format     | 
YYYY       | Year                                       | 
MM         | Month                                      | 
DD         | Day                                        | 
THH        | Hour in 24h format                         | 
T12HH      | Hour in 12h format                         | 
TMM        | Minutes                                    | 
TSS        | Seconds                                    | 
TFF        | Milliseconds                               | 
TAA        | AM/PM                                      | 

You can use `log::set_format(String fmt)` to change the format:

```c++
log::set_format("[%LEVEL5.5s] %FILEs:%LINEs [%FUNCs]: %MESSAGEs");
log::debug("Hello World");
//[DEBUG] main.c3:4 [main]: Hello World
log::set_format("[%LEVEL5.5s] [%ISO8601s] - %MESSAGEs");
log::debug("Hello World");
//[DEBUG] [2025-01-01 13:37:00] - Hello World 
```

## File Handlers
By default, the library logs to `stdout`. You can change this behavior with `log::add_handler(File* fp)` and `log::clear_handlers()`

```c++
log::debug("This message will be shown ONLY in stdout");

File fp = file::open("logs/custom.log", "w+")!!;
defer fp.close()!!;

log::add_handler(&fp);
log::debug("This message will be shown in stdout AND fp");

log::clear_handlers();
log::add_handler(&fp);
log::debug("This message will be shown ONLY in fp");
```