#include <vector>
#include <string>
#include <stdexcept>

struct Config
{
    std::vector<std::string> devices;

    unsigned vendorID, mouseDeviceID, keyboardDeviceID;

    std::string reverseMapScript;
    std::string profileScript;
};

class ConfigError: public std::runtime_error
{
public:
    ConfigError(std::string const &message);
};

void parseConfig(char const *configFile, Config &config);
void showConfig(Config &config);

inline ConfigError::ConfigError(std::string const &message)
    : std::runtime_error(message)
{
}
