#include <sys/ioctl.h>
#include <linux/input.h>
#include <glob.h>

#include <cstdlib>
#include <string>
#include <system_error>
#include <memory>
#include <iostream>

#include "DeviceFile.hh"

using std::make_error_code;
using std::errc;
using std::endl;
using std::cout;
using std::char_traits;
using std::unique_ptr;
using std::string;

void expand_file_glob(string &file_glob)
{
    unsigned try_count = 0;
    glob_t glob_result { };

    while (try_count < 5)
    {
	try_count++;

	switch (glob(file_glob.data(), GLOB_ERR | GLOB_NOSORT, nullptr, &glob_result))
	{
	case 0:
	    if (glob_result.gl_pathc == 1u)
		file_glob = glob_result.gl_pathv[0];
	    else
		file_glob.clear();

	    globfree(&glob_result);

	    if (file_glob.empty())
		throw make_error_code(errc::no_such_device_or_address);

	    return;
	case GLOB_NOSPACE:
	    throw make_error_code(errc::not_enough_memory);
	case GLOB_ABORTED:
	    throw make_error_code(errc::io_error);
	case GLOB_NOMATCH:
	    if (try_count < 5)
	    {
		// wait 5 seconds for USB device to be created and show up
		cout << "Waiting for device " << file_glob << "..." << endl;
		sleep(1);
		continue;
	    }
	    else
		throw make_error_code(errc::no_such_device);
	default:
	    throw make_error_code(errc::invalid_argument);
	}
    }
}

DeviceFD::DeviceFD(char const *device_file)
{
  char path[1024];

  fd = open(device_file, O_RDONLY);

  if (fd == -1)
  {
    auto local_error_code = make_error_code(static_cast<errc>(errno));

    cout << "Error: Couldn't open \"" << path << "\" for reading.\n";
    cout << "Reason: "<< local_error_code.message() << '.' << endl;
    cout << "Suggestion: Maybe a permission is missing. Try running this program with with sudo.\n";

    throw local_error_code;
  }

  api_call(ioctl, fd, EVIOCGRAB, 1);
  set_non_blocking();
}

