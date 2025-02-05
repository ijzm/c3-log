module log;

import std::io;
import std::time::datetime;
import std::collections::list;
import libc;

/*
Custom Naive implementation of isatty
Because it doesn't work correctly on Windows
*/
fn bool isatty(File* fp) {
	if(env::WIN32) {
		return (fp == io::stdout() || fp == io::stderr());
	}
	return (bool)libc::isatty(libc::fileno(fp.file));
}

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
	MESSAGE,

	COLOR,
	BACKGROUND,
	LEVEL,
	FILE,
	LINE,
	FUNC,


	ISO8601,

	YYYY,
	MM,
	DD,

	THH,
	T12HH,
	TMM,
	TSS,
	TFF,
	TAA,
}

const int MAX_FORMAT_SPEC_SIZE = 32;
const int MAX_FORMAT_SIZE      = 1024;
const int MAX_FILE_HANDLERS    = 32;

struct Log {
	Log_Level                             level;
	Log_Format_Spec[MAX_FORMAT_SPEC_SIZE] spec;
	int                                   count;
	char[MAX_FORMAT_SIZE]                 format;
	bool                                  local_timezone;

	File*[MAX_FILE_HANDLERS]               handlers;
	int                                    handlers_count;
}

Log global_log;

fn void initialize_log() @init {
	global_log.level = Log_Level.TRACE;
	global_log.local_timezone = true;
	global_log.handlers[0] = io::stdout();
	global_log.handlers_count = 1;
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
					i++;
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

	mem::set(&global_log.format, 0, MAX_FORMAT_SIZE);
	mem::copy(&global_log.format, new_format.zstr_view(), new_format.len());
	global_log.count = element_index;
}

fn void _log_print(Log_Level level, String file, int line, String func, String format, args...) @private {
	for(int i = 0; i < global_log.handlers_count; i++) {
		_log_print_single(
			global_log.handlers[i],
			level,
			file,
			line,
			func,
			format,
			...args
		);
	}
}


fn void _log_print_single(File* fp, Log_Level level, String file, int line, String func, String format, args...) @private {
	if(global_log.level > level) {
		return;
	}
	TzDateTime now = datetime::now().with_gmt_offset(0);
	if(global_log.local_timezone) {
		now = now.to_local();
	}

	DString buffer;
	defer buffer.free();

	List(<any>) list_str;
	list_str.new_init();
	defer list_str.free();

	DString value_buffer;
	defer value_buffer.free();
	value_buffer.appendf(format, ...args);

	for (int i = 0; i < MAX_FORMAT_SPEC_SIZE; i++) {
		switch (global_log.spec[i]) {
			case NONE:       list_str.push(&&"");
			case MESSAGE:    list_str.push(&&value_buffer.str_view());

			case COLOR:      {
				if(isatty(fp)){
					list_str.push(&level.color.value);
				} else {
					list_str.push(&&"");
				}
			}
			case BACKGROUND: {
				if(isatty(fp)){
					list_str.push(&level.background.value);
				} else {
					list_str.push(&&"");
				}
			}
			case LEVEL:      list_str.push(&&level.nameof);
			case FILE:       list_str.push(&file);
			case FUNC:       list_str.push(&func);
			case LINE:       list_str.push(&&line);

			case ISO8601: {
				String t = now.temp_format(DateTimeFormat.DATETIME);

				list_str.push(&&t);
			}

			case YYYY: list_str.push(&&now.year);
			case MM:   list_str.push(&&now.month.ordinal + 1);
			case DD:   list_str.push(&&now.day);

			case THH:   list_str.push(&&now.hour);
			case T12HH: {
				if (now.hour > 12) {
					list_str.push(&&(now.hour - 12));
				} else {
					list_str.push(&&now.hour);
				}
			}
			case TMM:   list_str.push(&&now.min);
			case TSS:   list_str.push(&&now.sec);
			case TFF:   list_str.push(&&now.usec);
			case TAA: {
				if (now.hour > 12) {
					list_str.push(&&"PM");
				} else {
					list_str.push(&&"AM");
				}
			}


			/*
			
			case HH_24:      io::fprint(values[i], "");
			case HH_12:      io::fprint(values[i], "");
			case MINUTE:     io::fprint(values[i], "");
			case SECOND:     io::fprint(values[i], "");
			case MILISECOND: io::fprint(values[i], "");*/
		}
	}

	DString format_buffer;
	defer format_buffer.free();
	format_buffer.appendf("%s", (ZString)global_log.format[..]);
	buffer.appendf(
		format_buffer.str_view(),
		...list_str.to_tarray()[:MAX_FORMAT_SPEC_SIZE],
	);

	if(isatty(fp)) {
		buffer.appendf(
			"%s%s",
			Terminal_Color.RESET.value,
			Terminal_Background.RESET.value,
		);
	}

	io::fprintn(fp, buffer.str_view())!!;
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