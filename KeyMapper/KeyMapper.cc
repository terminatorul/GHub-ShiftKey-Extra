#include <sys/epoll.h>
#include <linux/input.h>
#include <unistd.h>

#include <errno.h>

#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <exception>
#include <stdexcept>
#include <system_error>
#include <memory>
#include <type_traits>
#include <utility>
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <iomanip>
#include <fstream>

#include <lua.hpp>

#include "DeviceFile.hh"
#include "ConfigFile.hh"

using std::size_t;
using std::uintptr_t;
using std::exception;
using std::runtime_error;
using std::make_error_code;
using std::error_code;
using std::system_category;
using std::errc;
using std::string;
using std::vector;
using std::map;
using std::ifstream;
using std::cout;
using std::clog;
using std::cerr;
using std::endl;
using std::flush;
using std::setw;

using namespace std::literals::string_literals;

// ADD KEY->COMMAND MAPPINGS HERE:
// char const *downCommands[] = {
  //[scancode] = "command to run",
  /*
  [4] = "xdotool key Page_Up", // scroll left
  [5] = "xdotool key Page_Down", // scroll right
  [6] = "xdotool key ctrl+c", // G8
  [7] = "xdotool key ctrl+shift+c", // G7
  [8] = "i3-msg workspace next_on_output", // G9
  [9] = "i3-msg move workspace next_on_output", // G10
  [10] = "xdotool key ctrl+w", // G11
  [11] = "pulseaudio-ctl down", // G12
  [12] = "pulseaudio-ctl mute", // G13
  [13] = "xdotool key ctrl+z", // G14
  [14] = "xdotool key End", // G15
  [15] = "xdotool key ctrl+End", // G16
  [16] = "xdotool key Return", // G17
  [17] = "i3-msg fullscreen", // G18
  [18] = "xdotool key ctrl+slash t", // G19
  [19] = "", // G20
  [20] = "xdotool key alt+Left", // G-shift + scroll left
  [21] = "xdotool key alt+Right", // G-shift + scroll right
  [22] = "xdotool key ctrl+v", // G-shift + G8
  [23] = "xdotool key ctrl+shift+v", // G-shift + G7
  [24] = "i3-msg workspace prev_on_output", // G-shift + G9
  [25] = "i3-msg move workspace prev_on_output", // G-shift + G10
  [26] = "i3-msg kill", // G-shift + G11
  [27] = "pulseaudio-ctl up", // G-shift + G12
  [28] = "pulseaudio-ctl mute", // G-shift + G13
  [29] = "xdotool key ctrl+shift+z ctrl+y", // G-shift + G14
  [30] = "xdotool key Home", // G-shift + G15
  [31] = "xdotool key ctrl+Home", // G-shift + G16
  [32] = "xdotool key Escape", // G-shift + G17
  [33] = "i3-msg fullscreen", // G-shift + G18
  [34] = "", // G-shift + G19
  [35] = "", // G-shift + G20
  [37] = "echo button down"
  */
// };

// const char *upCommands[] =
// {
//   //[scancode] = "command to run",
//   //[37] = "echo button up"
// };

class LuaError: public runtime_error
{
public:
    LuaError(char const *message);
};

LuaError::LuaError(char const *message)
    : runtime_error(message)
{
}

void error(lua_State *L, char const *fmt, ...)
{
    char error_message[2048];

    va_list argp;
    va_start(argp, fmt);
    vsprintf(error_message, fmt, argp);
    va_end(argp);
    lua_close(L);

    throw LuaError(error_message);
}

class SyntaxError: public runtime_error
{
public:
    SyntaxError()
	: runtime_error(string())
    {
    }
};

void handle_fd_event(epoll_event &ev, uintptr_t pCallbackCookie)
try
{
    if (ev.events & EPOLLERR)
	throw runtime_error("Error reading input device"s);

    map<int, int> &deviceMap = *static_cast<map<int, int> *>(reinterpret_cast<void *>(pCallbackCookie));

    auto it = deviceMap.find(ev.data.fd);

    if (it == deviceMap.end())
	return;

    struct input_event events[64];
    ssize_t n =  api_call(read, ev.data.fd, events, sizeof(events));

    if (n < sizeof(struct input_event))
	return;

    for (unsigned i = 0u; n >= sizeof events[0]; n -= sizeof events[0], i++)
	if (events[i].type != EV_SYN || events[i].code != 0 || events[i].value != 0)
	{
	    if (events[i].type == EV_REL && (events[i].code == 0 || events[i].code == 1))
		return;

	    clog << "FD: " << it->second;

	    switch (events[i].type)
	    {
		case EV_SYN:
		    clog << ", EV_SYN: ";
		    break;
		case EV_KEY:
		    clog << ", EV_KEY: ";
		    break;
		case EV_REL:
		    clog << ", EV_REL: ";
		    break;
		case EV_ABS:
		    clog << ", EV_ABS: ";
		    break;
		case EV_MSC:
		    clog << ", EV_MSC: ";
		    break;
		case EV_SW:
		    clog << ", EV_SW: ";
		    break;
		case EV_LED:
		    clog << ", EV_LED: ";
		    break;
		case EV_SND:
		    clog << ", EV_SND: ";
		    break;
		case EV_REP:
		    clog << ", EV_REP: ";
		    break;
		case EV_FF:
		    clog << ", EV_FF: ";
		    break;
		case EV_PWR:
		    clog << ", EV_PWR: ";
		    break;
		case EV_FF_STATUS:
		    clog << ", EV_FF_STATUS: ";
		    break;
		default:
		    clog << ", Type: " << events[i].type;
	    }

	    clog << ", code: " << setw(3) << events[i].code << ", value: " << setw(6) << events[i].value << endl;
	}
}
catch (error_code const &error_code)
{
    if (error_code.category() == system_category() && (error_code.value() == EAGAIN || error_code.value() == EWOULDBLOCK))
	return;

    throw;
}

#define TO_STRING(arg) #arg

int main(int argc, char const *argv[])
try
{
    cout << "Starting Linux HID KeyMapper..." << endl;

    Config config;

    if (argc == 1)
	parseConfig(TO_STRING(KEYMAPPER_ETC_DIR) "/KeyMapper/KeyMapper.conf", config);
    else
	if (argc == 3 && "--config"s == argv[1])
	    parseConfig(argv[2], config);
	else
	    throw SyntaxError();

    vector<DeviceFD> devices;
    map<int, int> deviceMap;
    EdgePollInstance pollInstance(config.devices.size(), reinterpret_cast<uintptr_t>(&deviceMap));
    epoll_event ev { };

    ev.events = EPOLLIN | EPOLLERR;
    devices.reserve(config.devices.size());

    for (auto &deviceName: config.devices)
    {
	expand_file_glob(deviceName);
	devices.emplace_back(deviceName.c_str());
	ev.data.fd = devices.rbegin()->fd;
	deviceMap[ev.data.fd] = devices.size() - 1u;
	clog << "Device " << deviceMap[ev.data.fd] << ": " << deviceName << endl;
	pollInstance.add(ev);
    }

    cout << "Linux HID KeyMapper started.\n\n" << flush;

    vector<epoll_event> input_events(config.devices.size());

    while (true)
	pollInstance.poll(input_events, handle_fd_event);
}
catch (SyntaxError const &)
{
    cerr << "Syntax:\n";
    cerr << "\t" << argv[0] << " [--config /etc/local/KeyMapper/KeyMapper.conf]\n";
    cerr << endl;
    cerr << "Run script file with macros and key mappings for a HID input device." << endl;

    return 255;
}
catch (ConfigError const &ex)
{
    cerr << ex.what() << endl;
    return EXIT_FAILURE;
}
catch (error_code const &ex)
{
    cerr << "Application error: " << ex.message() << endl;
    return EXIT_FAILURE;
}
catch (exception const &ex)
{
    cerr << "Application error: " << ex.what() << endl;
    cerr << "Terminated" << endl;

    return EXIT_FAILURE;
}
catch (...)
{
    cerr << "Terminated" << endl;

    return EXIT_FAILURE;
}
