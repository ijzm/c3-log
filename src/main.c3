import std::io;
import libc;

import log;

fn void main() {
mem::@report_heap_allocs_in_scope() {

	File fp = file::open("logs/custom.log", "w+")!!;
	defer fp.close()!!;
	log::global_log.handlers[1] = &fp;
	log::global_log.handlers_count++;

	io::printfn("Print All Log Types-------------------------------------");
	log::trace("This is a [trace] message %s!", 42);
	log::debug("This is a [debug] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);
	log::notif("This is a [notif] message %s!", 42);
	log::warn ("This is a [warn ] message %s!", 42);
	log::error("This is a [error] message %s!", 42);
	log::fatal("This is a [fatal] message %s!", 42);

	io::printfn("Set Level-----------------------------------------------");
	log::set_level(Log_Level.NOTIF);
	log::trace("This is a [trace] message %s!", 42);
	log::debug("This is a [debug] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);
	log::notif("This is a [notif] message %s!", 42);
	log::warn ("This is a [warn ] message %s!", 42);
	log::error("This is a [error] message %s!", 42);
	log::fatal("This is a [fatal] message %s!", 42);

	io::printfn("Set Format----------------------------------------------");
	log::set_level(Log_Level.TRACE);
	log::set_format("%COLORs%BACKGROUNDs%LEVEL3.3s - %FILEs:%LINEs - %FUNCs - %MESSAGEs");
	log::trace("This is a [trace] message %s!", 42);
	log::debug("This is a [debug] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);

	io::printfn("Set Format - Timestamps---------------------------------");
	log::set_format("%COLORs%BACKGROUNDs[%ISO8601s][%YYYYs-%MM02d-%DD02d %T12HH02d:%TMMs:%TSSs.%TFFs %TAAs]");
	log::trace("This is a [trace] message %s!", 42);
	log::debug("This is a [debug] message %s!", 42);
	log::info ("This is a [info ] message %s!", 42);
};
}