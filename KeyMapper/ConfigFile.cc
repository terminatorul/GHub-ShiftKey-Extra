#include <cctype>
#include <string>
#include <stdexcept>
#include <utility>
#include <sstream>
#include <algorithm>
#include <iostream>
#include <iomanip>

#include "DeviceFile.hh"
#include "ConfigFile.hh"

using std::invalid_argument;
using std::out_of_range;
using std::move;
using std::isspace;
using std::string;
using std::stoul;
using std::getline;
using std::istringstream;
using std::find;
using std::clog;
using std::endl;
using std::setw;
using std::hex;

using namespace std::literals::string_literals;

enum class Section { None, Device, Options, Scripts };

string read_file_content(int fd)
{
    char page[4u * 1024u];
    string content;

    while (int read_size = api_call(::read, fd, page, sizeof page))
	content.append(page, read_size);


    return move(content);
}

void trimWhiteSpace(string &line)
{
    auto it = line.begin();

    while (it != line.end() && std::isspace(*it))
	it++;

    line.erase(line.begin(), it);

    auto jt = line.rbegin();

    while (jt != line.rend() && std::isspace(*jt))
	jt++;

    line.resize(line.size() - (jt - line.rbegin()));
}

static void parseDeviceSection(string const &name, string &&value, Config &config)
try
{
    unsigned long interface = stoul(name);

    if (interface != config.devices.size())
	throw ConfigError("Wrong device order in config file."s);

    config.devices.emplace_back(move(value));
}
catch (invalid_argument const &)
{
    throw ConfigError("Wrong value syntax in config file."s);
}
catch (out_of_range const &)
{
    throw ConfigError("Wrong value syntax in config file."s);
}

unsigned long readHexInteger(string const &string_value)
try
{
    return stoul(string_value, nullptr, 16);
}
catch (invalid_argument const &)
{
    throw ConfigError("Wrong hexadecimal value syntax in config file."s);
}
catch (out_of_range const &)
{
    throw ConfigError("Wrong hexadecimal value syntax in config file."s);
}

static void parseOptionSection(string const &name, string const &value, Config &config)
{
    if (name == "usb vendor id"s)
	config.vendorID = readHexInteger(value);
    else
	if (name == "usb keyboard device id"s)
	    config.keyboardDeviceID = readHexInteger(value);
	else
	    if (name == "usb mouse device id"s)
		config.mouseDeviceID = readHexInteger(value);
	    else
		throw ConfigError("Unexpected option given in config file.");
}

static void parseScriptSection(string const &name, string &&value, Config &config)
{
    if (name == "reverse map"s)
	config.reverseMapScript = move(value);
    else
	if (name == "profile"s)
	    config.profileScript = move(value);
	else
	    throw ConfigError("Unexpected option given in config file.");
}

void parseConfigLine(string &line, Config &config, Section &section)
{
    trimWhiteSpace(line);

    if (line.empty() || line[0] == ';')
	return;

    if (line[0] == '[')
	if (line == "[device]"s)
	    section = Section::Device;
	else
	    if (line == "[options]"s)
		section = Section::Options;
	    else
		if (line == "[scripts]")
		    section = Section::Scripts;
		else
		    throw ConfigError("Unexpected section in config file."s);
    else
    {
	auto it = find(line.begin(), line.end(), '='), jt = it;

	while (it != line.begin() && isspace(*(it - 1)))
	    it--;

	if (jt != line.end())
	{
	    jt++;

	    while (jt != line.end() && isspace(*jt))
		jt++;
	}

	if (it == line.end() || it == line.begin() || jt == line.end())
	    throw ConfigError("Wrong value syntax in config file."s);

	switch (section)
	{
	case Section::None:
	    throw ConfigError("Missing section name in config file."s);

	case Section::Device:
	    parseDeviceSection(string(line.begin(), it), string(jt, line.end()), config);
	    break;

	case Section::Options:
	    parseOptionSection(string(line.begin(), it), string(jt, line.end()), config);
	    break;

	case Section::Scripts:
	    parseScriptSection(string(line.begin(), it), string(jt, line.end()), config);
	    break;
	}
    }
}

void parseConfig(char const *configFile, Config &config)
{
    config = Config { };
    Section section = Section::None;

    DeviceFD fd(api_call(open, configFile, O_RDONLY));
    istringstream configStr(read_file_content(fd.fd));
    string configLine;

    while (getline(configStr, configLine))
	parseConfigLine(configLine, config, section);

    if (configStr.bad() || !configStr.eof())
	throw ConfigError("Error parsing config file."s);

    if (config.devices.empty() || !config.vendorID || !config.keyboardDeviceID || !config.mouseDeviceID
	    || config.reverseMapScript.empty() || config.profileScript.empty())
    {
	throw ConfigError("Incomplete list of options in config file."s);
    }
}

void showConfig(Config &config)
{
    for (auto const &device: config.devices)
	clog << "Device file:           " << device << endl;

    clog << "USB vendor ID:         0x" << hex << setw(4) << config.vendorID << endl;
    clog << "Keboard device ID:     0x" << hex << setw(4) << config.keyboardDeviceID << endl;
    clog << "Mouse device ID:       0x" << hex << setw(4) << config.mouseDeviceID << endl;
    clog << "Revese mapping script: " << config.reverseMapScript << endl;
    clog << "Profile script:        " << config.profileScript << endl;

    clog << endl;
}

