module log;

import std::io;
import std::time::datetime;
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
	NONE,

	COLOR,
	BACKGROUND,
	LEVEL,
	FILE,
	LINE,
	FUNC,

	MESSAGE,
/*
	ISO8601,
	YYYY,
	MM,
	DD,
	
	HH_24,
	HH_12,
	MINUTE,
	SECOND,
	MILISECOND,
*/
}

const int MAX_LOG_LIST_SIZE = 32;

struct Log {
	Log_Level                          level;
	Log_Format_Spec[MAX_LOG_LIST_SIZE] spec;
	int                                count;
	String                             format;
}

Log global_log;

fn void initialize_log() @init {
	global_log.level = Log_Level.TRACE;
	set_format("%COLORs%BACKGROUNDs[%LEVEL5.5s] %FILEs:%LINEs [%FUNCs]: %MESSAGEs");
}

fn void set_level(Log_Level level) {
	global_log.level = level;
}

fn void set_format(String fmt) {
	DString new_format;
	defer new_format.free();

	int element_index = 0;

	for(int i = 0; i < fmt.len; i++) {
		switch(fmt[i]) {
			case '%': {
				if((fmt[i+1..]).starts_with("%")) {
					i += 1;

					new_format.append_chars("%%");
					continue;
				}
				foreach (Log_Format_Spec element : Log_Format_Spec.values) {
					if((fmt[i+1..]).starts_with(element.nameof)) {
						new_format.append_char('%');
						i += element.nameof.len;
						global_log.spec[element_index++] = element;
					}
				}
			}
			default: {
				new_format.append_char(fmt[i]);
			}
		}
	}

	global_log.format = new_format.str_view();
	global_log.count = element_index;
}

fn void _log_print(Log_Level level, String file, int line, String func, String format, args...) @private {
	if(global_log.level > level) {
		return;
	}
	//TzDateTime now = datetime::now().to_local();

	DString buffer;
	defer buffer.free();

	

	List(<any>) list_str;
	list_str.new_init();
	defer list_str.free();

	for (int i = 0; i < MAX_LOG_LIST_SIZE; i++) {
		switch (global_log.spec[i]) {
			case NONE:    list_str.push(&&"");
			case MESSAGE: {
				DString value_buffer;
				defer value_buffer.free();

				value_buffer.appendf(format, ...args);
				list_str.push(&&value_buffer.str_view());
			};

			case COLOR:      list_str.push(&level.color.value);
			case BACKGROUND: list_str.push(&level.background.value);
			case LEVEL:      list_str.push(&&level.nameof);
			case FILE:       list_str.push(&file);
			case FUNC:       list_str.push(&func);
			case LINE:       list_str.push(&&line);

			/*

			case ISO8601: io::fprint(values[i], "");

			case YYYY: io::fprint(values[i], "");
			case MM:   io::fprint(values[i], "");
			case DD:   io::fprint(values[i], "");
			
			case HH_24:      io::fprint(values[i], "");
			case HH_12:      io::fprint(values[i], "");
			case MINUTE:     io::fprint(values[i], "");
			case SECOND:     io::fprint(values[i], "");
			case MILISECOND: io::fprint(values[i], "");*/
		}
	}

	buffer.appendf(
		global_log.format,
		...list_str.to_tarray()[:MAX_LOG_LIST_SIZE],
	);

	buffer.appendf(
		"%s%s",
		Terminal_Color.RESET.value,
		Terminal_Background.RESET.value,
	);

	io::printn(buffer.str_view());
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