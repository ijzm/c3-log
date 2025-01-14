module log;

import std::io;
import std::collections::list;

enum Terminal_Color : int (String value) {
	BLACK          = "\x1B[30m",
	RED            = "\x1B[31m",
	GREEN          = "\x1B[32m",
	YELLOW         = "\x1B[33m",
	BLUE           = "\x1B[34m",
	MAGENTA        = "\x1B[35m",
	CYAN           = "\x1B[36m",
	WHITE          = "\x1B[37m",

	BRIGHT_BLACK   = "\x1B[90m",
	BRIGHT_RED     = "\x1B[91m",
	BRIGHT_GREEN   = "\x1B[92m",
	BRIGHT_YELLOW  = "\x1B[93m",
	BRIGHT_BLUE    = "\x1B[94m",
	BRIGHT_MAGENTA = "\x1B[95m",
	BRIGHT_CYAN    = "\x1B[96m",
	BRIGHT_WHITE   = "\x1B[97m",

	RESET          = "\x1B[39m",
}

enum Terminal_Background : int (String value) {
	BLACK          = "\x1B[40m",
	RED            = "\x1B[41m",
	GREEN          = "\x1B[42m",
	YELLOW         = "\x1B[43m",
	BLUE           = "\x1B[44m",
	MAGENTA        = "\x1B[45m",
	CYAN           = "\x1B[46m",
	WHITE          = "\x1B[47m",

	BRIGHT_BLACK   = "\x1B[100m",
	BRIGHT_RED     = "\x1B[101m",
	BRIGHT_GREEN   = "\x1B[102m",
	BRIGHT_YELLOW  = "\x1B[103m",
	BRIGHT_BLUE    = "\x1B[104m",
	BRIGHT_MAGENTA = "\x1B[105m",
	BRIGHT_CYAN    = "\x1B[106m",
	BRIGHT_WHITE   = "\x1B[107m",

	RESET          = "\x1B[49m",
}

enum Log_Level : int (Terminal_Color color, Terminal_Background background){
	TRACE = { Terminal_Color.RESET, Terminal_Background.RESET },
	DEBUG = { Terminal_Color.GREEN, Terminal_Background.RESET },
	INFO  = { Terminal_Color.YELLOW, Terminal_Background.RESET },
	NOTIF = { Terminal_Color.CYAN, Terminal_Background.RESET },
	WARN  = { Terminal_Color.BLACK, Terminal_Background.YELLOW },
	ERROR = { Terminal_Color.BRIGHT_RED, Terminal_Background.RESET },
	FATAL = { Terminal_Color.WHITE, Terminal_Background.RED },
}

enum Log_Format_Spec {
	COLOR,
	BACKGROUND,
	LEVEL,
	FILE,
	LINE,
	FUNC,
	MESSAGE,
}

// Defaults (Global):
Log_Level log_level  = Log_Level.TRACE;
String log_format = "%COLORs%BACKGROUNDs[%LEVEL5.5s] %FILEs:%LINEs [%FUNCs]: %MESSAGEs";

fn void set_level(Log_Level level) {
	log_level = level;
}

fn void set_format(String new_fmt) {
	log_format = new_fmt;
}

fn void _log_print(Log_Level level, String file, int line, String func, String format, args...) @private {
	if(log_level > level) {
		return;
	}

	DString buffer;
	defer buffer.free();

	DString format_buffer;
	defer format_buffer.free();

	String message = string::new_format(format, ...args);
	defer message.free();

	for(int i = 0; i < log_format.len; i++) {
		switch(log_format[i]) {
			case '%': {
				if((log_format[i+1..]).starts_with("%")) {
					i += 1;

					buffer.appendf("%s", "%%");
					continue;
				}
				foreach (Log_Format_Spec element : Log_Format_Spec.values) {
					if((log_format[i+1..]).starts_with(element.nameof)) {
						format_buffer.clear();
						i += element.nameof.len;

						format_buffer.appendf("%s", "%");
						usz format_index = log_format.index_of_char_from('s', (usz)(i + 1))!!;
						format_buffer.appendf("%s", log_format[i + 1..format_index]);

						String new_format = format_buffer.str_view();
						i += new_format.len - 1;

						switch (element) {
							case COLOR:      buffer.appendf(new_format, level.color.value);
							case BACKGROUND: buffer.appendf(new_format, level.background.value);
							case LEVEL:      buffer.appendf(new_format, level);
							case FILE:       buffer.appendf(new_format, file);
							case LINE:       buffer.appendf(new_format, line);
							case FUNC:       buffer.appendf(new_format, func);
							case MESSAGE:    buffer.appendf(new_format, message);
						}
					}
				}
			}
			default: {
				buffer.append_char(log_format[i]);
			}
		}
	}

	buffer.appendf(
		"%s%s",
		Terminal_Color.RESET.value,
		Terminal_Background.RESET.value,
	);

	io::printfn(buffer.str_view());
}
	

macro trace(format, args...) {
	_log_print(Log_Level.TRACE, $$FILE, $$LINE, $$FUNC, format, ...args );
}
macro debug(format, args...) {
	_log_print(Log_Level.DEBUG, $$FILE, $$LINE, $$FUNC, format, ...args );
}
macro info(format, args...) {
	_log_print(Log_Level.INFO, $$FILE, $$LINE, $$FUNC, format, ...args );
}
macro notif(format, args...) {
	_log_print(Log_Level.NOTIF, $$FILE, $$LINE, $$FUNC, format, ...args );
}
macro warn(format, args...) {
	_log_print(Log_Level.WARN, $$FILE, $$LINE, $$FUNC, format, ...args );
}
macro error(format, args...) {
	_log_print(Log_Level.ERROR, $$FILE, $$LINE, $$FUNC, format, ...args );
}
macro fatal(format, args...) {
	_log_print(Log_Level.FATAL, $$FILE, $$LINE, $$FUNC, format, ...args );
}