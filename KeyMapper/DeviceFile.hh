#include <sys/epoll.h>
#include <dirent.h>
#include <fcntl.h>
#include <unistd.h>

#include <cstdint>
#include <system_error>
#include <type_traits>
#include <utility>
#include <string>
#include <vector>

template <typename FunctionT, typename... ArgsT>
    std::invoke_result_t<FunctionT, ArgsT...> api_call(FunctionT fn, ArgsT... args);

template <typename FunctionT, typename... ArgsT>
    std::invoke_result_t<FunctionT, ArgsT...> check_call(FunctionT fn, ArgsT... args);

template <typename FunctionT, typename... ArgsT>
    std::invoke_result_t<FunctionT, ArgsT...> silent_api_call(FunctionT fn, ArgsT... args);

char const *find_hid_dev(char *path, char const *suffix);
void expand_file_glob(std::string &file_glob);

class DeviceFD
{
protected:
    void set_non_blocking();

public:
    int fd;
    DeviceFD(char const *device_file);
    DeviceFD(int fd);
    void close();
    ~DeviceFD();
};

class EdgePollInstance: public DeviceFD
{
protected:
    std::uintptr_t pCallbackCookie;

public:
    EdgePollInstance(unsigned size, std::uintptr_t pCallbackCookie);
    void add(struct epoll_event &ev);
    template <unsigned SIZE>
	void poll(epoll_event (&events)[SIZE], void (*event_fn)(epoll_event &ev, uintptr_t pCallbackCookie));
    void poll(std::vector<epoll_event> &events, void (*event_fn)(epoll_event &ev, uintptr_t pCallbackCookie));
};

// inline functions and templates

template <typename FunctionT, typename... ArgsT>
    std::invoke_result_t<FunctionT, ArgsT...> api_call(FunctionT fn, ArgsT... args)
{
    std::invoke_result_t<FunctionT, ArgsT...> returnCode = fn(std::forward<ArgsT>(args)...);

    if (returnCode == -1)
	throw std::make_error_code(static_cast<std::errc>(errno));

    return returnCode;
}

template <typename FunctionT, typename... ArgsT>
    std::invoke_result_t<FunctionT, ArgsT...> check_call(FunctionT fn, ArgsT... args)
{
    std::invoke_result_t<FunctionT, ArgsT...> returnCode = fn(std::forward<ArgsT>(args)...);

    if (!returnCode)
	throw std::make_error_code(static_cast<std::errc>(errno));

    return returnCode;
}

template <typename FunctionT, typename... ArgsT>
    std::invoke_result_t<FunctionT, ArgsT...> silent_api_call(FunctionT fn, ArgsT... args)
{
    auto returnCode = fn(std::forward<ArgsT>(args)...);

    if (returnCode == -1)
	if (!std::uncaught_exceptions())
	    throw std::make_error_code(static_cast<std::errc>(errno));

    return returnCode;
}

inline DeviceFD::~DeviceFD()
{
    close();
}

inline DeviceFD::DeviceFD(int fd)
    : fd(fd)
{
}

inline void DeviceFD::set_non_blocking()
{
    api_call(fcntl, fd, F_SETFL, api_call(fcntl, fd, F_GETFL) | O_NONBLOCK);
}

inline void DeviceFD::close()
{
    if (fd != -1)
    {
	silent_api_call(::close, fd);
	fd = -1;
    }
}

inline EdgePollInstance::EdgePollInstance(unsigned size, std::uintptr_t pCallbackCookie)
    : DeviceFD(api_call(::epoll_create, size)), pCallbackCookie(pCallbackCookie)
{
}

inline void EdgePollInstance::add(epoll_event &ev)
{
    api_call(epoll_ctl, fd, EPOLL_CTL_ADD, ev.data.fd, &ev);
}

template <unsigned SIZE>
    inline void EdgePollInstance::poll(epoll_event (&events)[SIZE], void (*event_fn)(epoll_event &ev, uintptr_t pCallbackCookie))
{
    int count = api_call(epoll_wait, fd, events, SIZE, -1);

    for (int i = 0; i < count; i++)
	event_fn(events[i], pCallbackCookie);
}

inline void EdgePollInstance::poll(std::vector<epoll_event> &events, void (*event_fn)(epoll_event &ev, uintptr_t pCallbackCookie))
{
    int count = api_call(epoll_wait, fd, events.data(), events.size(), -1);

    for (int i = 0; i < count; i++)
	event_fn(events[i], pCallbackCookie);
}
