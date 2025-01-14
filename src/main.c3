import std::io;

import log;

fn void main() {

	//[..^1]?
	//Print all Colors
	/*
	foreach(Terminal_Color color : Terminal_Color.values[..^2]){
		foreach(Terminal_Background background : Terminal_Background.values[..^2]){
			io::printf(
				"%s%s TEST %s%s",
				color.value, background.value,
				Terminal_Color.RESET.value, Terminal_Background.RESET.value,
			);
		}
		io::printf("\n");
	}
	*/
	
	io::printf("\n");
	io::printf("\n");
mem::@report_heap_allocs_in_scope() {
	//Print All Log Types
	log::trace("This is a [trace] message %s!", 42);
	log::debug("This is a [debug] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);
	log::notif("This is a [notif] message %s!", 42);
	log::warn ("This is a [warn ] message %s!", 42);
	log::error("This is a [error] message %s!", 42);
	log::fatal("This is a [fatal] message %s!", 42);

	io::printfn("--------------------------------------------------------");

	log::set_level(Log_Level.INFO);
	log::trace("This is a [trace] message %s!", 42);
	log::debug("This is a [debug] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);
	log::notif("This is a [notif] message %s!", 42);
	log::warn ("This is a [warn ] message %s!", 42);
	log::error("This is a [error] message %s!", 42);
	log::fatal("This is a [fatal] message %s!", 42);

	io::printfn("--------------------------------------------------------");
	log::set_format("%COLORs%BACKGROUNDs%LEVEL3.3s - %FILEs:%LINEs - %FUNCs - %MESSAGEs");
	log::set_level(Log_Level.TRACE);
	log::debug("This is a [debug] message %s!", 42);
	log::trace("This is a [trace] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);

	log::notif("Testing new format");
	log::warn ("Testing new format");
	log::error("Testing new format");
	log::fatal("Testing new format");

};
}