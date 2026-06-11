# GCC — Error Codes

## C Standard Error Codes

| Code | Header | Meaning |
| ---- | ------ | ------- |
| `0` | — | Success |
| `1` | `EOF` | End of file |
| `ENOMEM` | `stdlib.h` | Out of memory |
| `EINVAL` | `stdlib.h` | Invalid argument |
| `ERANGE` | `stdlib.h` | Result out of range |
| `ENOMEM` | `stdlib.h` | Not enough memory |
| `ENOENT` | `errno.h` | No such file or directory |
| `EEXIST` | `errno.h` | File already exists |
| `EAGAIN` | `errno.h` | Resource temporarily unavailable |
| `EACCES` | `errno.h` | Permission denied |
| `EBADF` | `errno.h` | Bad file descriptor |
| `EINTR` | `errno.h` | Interrupted system call |
| `EIO` | `errno.h` | I/O error |
| `EMFILE` | `errno.h` | Too many open files |
| `ENFILE` | `errno.h` | File table overflow |
| `ENOSPC` | `errno.h` | No space left on device |
| `EPERM` | `errno.h` | Operation not permitted |
| `EPIPE` | `errno.h` | Broken pipe |
| `ESRCH` | `errno.h` | No such process |
| `EFAULT` | `errno.h` | Bad address |
| `ENOTTY` | `errno.h` | Not a tty |
| `EILSEQ` | `errno.h` | Illegal sequence |
| `ECONNRESET` | `errno.h` | Connection reset |
| `ETIMEDOUT` | `errno.h` | Connection timed out |

### Common errno Values

```c
#include <errno.h>
#include <string.h>

// Get human-readable error message
const char *err_msg = strerror(errno);

// Print error with prefix
perror("error");        // prints "error: <message>"
fprintf(stderr, "%s\n", strerror(errno));
```

---

## OpenSSL Error Codes

| Code | Meaning |
| ---- | ------- |
| `SSL_ERROR_NONE` | No error |
| `SSL_ERROR_ZERO_RETURN` | Connection closed |
| `SSL_ERROR_WANT_READ` | Need more data to read |
| `SSL_ERROR_WANT_WRITE` | Need to write more data |
| `SSL_ERROR_SYSCALL` | Syscall error |
| `SSL_ERROR_SSL` | SSL/TLS protocol error |
| `SSL_ERROR_EOF` | Unexpected EOF |

```c
#include <openssl/err.h>

// Print OpenSSL errors
void print_ssl_errors(void) {
    unsigned long err;
    while ((err = ERR_get_error()) != 0) {
        char buf[128];
        ERR_error_string_n(err, buf, sizeof(buf));
        fprintf(stderr, "SSL error: %s\n", buf);
    }
}
```

---

## cURL Error Codes

| Code | Constant | Meaning |
| ---- | -------- | ------- |
| `0` | `CURLE_OK` | Success |
| `1` | `CURLE_UNSUPPORTED_PROTOCOL` | Unsupported protocol |
| `2` | `CURLE_FAILED_INIT` | Initialization failed |
| `6` | `CURLE_COULDNT_RESOLVE_HOST` | DNS lookup failed |
| `7` | `CURLE_FAILED_CONNECT` | Connection failed |
| `28` | `CURLE_OPERATION_TIMEDOUT` | Operation timed out |
| `35` | `CURLE_SSL_CONNECT_ERROR` | SSL/TLS connection error |
| `56` | `CURLE_RECV_ERROR` | Receive error |
| `59` | `CURLE_SSL_CERTPROBLEM` | SSL certificate problem |
| `60` | `CURLE_SSL_CACERT` | SSL CA certificate error |
| `77` | `CURLE_SSL_CACERT_BADFILE` | Bad CA certificate file |
| `78` | `CURLE_REMOTE_ACCESS_DENIED` | Access denied |
| `92` | `CURLE_HTTP2` | HTTP/2 stream error |
| `56` | `CURLE_RECV_ERROR` | Receive error |

```c
#include <curl/curl.h>

const char *curl_err = curl_easy_strerror(CURL_E_OK);
```

---

## Socket Error Codes

| Code | Constant | Meaning |
| ---- | -------- | ------- |
| `ECONNREFUSED` | — | Connection refused |
| `ECONNRESET` | — | Connection reset by peer |
| `EINPROGRESS` | — | Connection in progress |
| `EISCONN` | — | Already connected |
| `ENOTCONN` | — | Not connected |
| `EADDRINUSE` | — | Address already in use |
| `EADDRNOTAVAIL` | — | Address not available |
| `EAFNOSUPPORT` | — | Address family not supported |
| `EWOULDBLOCK` | — | Operation would block |

---

## Database Error Codes (sqlite3)

| Code | Constant | Meaning |
| ---- | -------- | ------- |
| `0` | `SQLITE_OK` | Successful result |
| `1` | `SQLITE_ERROR` | SQL error or missing database |
| `5` | `SQLITE_MISUSE` | Library misuse |
| `11` | `SQLITE_FULL` | Database is full |
| `14` | `SQLITE_CANTOPEN` | Can't open database |
| `19` | `SQLITE_CONSTRAINT` | Constraint violation |
| `26` | `SQLITE_BUSY` | Database is locked |
| `21` | `SQLITE_MISMATCH` | Data type mismatch |

---

## Thread Error Codes

| Code | Constant | Meaning |
| ---- | -------- | ------- |
| `0` | `PTHREAD_SUCCESSFUL_NP` | Success |
| `11` | `EAGAIN` | Resource temporarily unavailable |
| `12` | `ENOMEM` | Not enough memory |
| `16` | `EBUSY` | Device or resource busy |
| `22` | `EINVAL` | Invalid argument |
| `24` | `EMFILE` | Too many open files |
| `35` | `EDEADLK` | Deadlock |

---

## Debugging Error Codes

### GDB Exit Codes

| Code | Meaning |
| ---- | ------- |
| `0` | Normal exit |
| `1` | Error in command |
| `2` | Error in GDB |
| `3` | Fatal error |
| `4` | Breakpoint hit |
| `5` | Signal received |

### Valgrind Exit Codes

| Code | Meaning |
| ---- | ------- |
| `0` | No errors detected |
| `42` | Memory leaks detected |
| `86` | Serious errors |
| `128+` | Signal number |

### Sanitizer Exit Codes

| Sanitizer | Exit Code | Meaning |
| --------- | --------- | ------- |
| ASan | `1` | Address error |
| ASan | `64` | Memory error |
| ASan | `86` | Serious error |
| UBSan | `1` | Undefined behavior |
| UBSan | `2` | Multiple undefined behaviors |
| TSan | `64` | Thread race detected |

---

## Common Error Patterns

### Memory Allocation Errors

```c
#include <stdio.h>
#include <stdlib.h>

void *safe_malloc(size_t size) {
    void *ptr = malloc(size);
    if (!ptr) {
        fprintf(stderr, "malloc failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    return ptr;
}

char *safe_strdup(const char *s) {
    char *p = strdup(s);
    if (!p) {
        fprintf(stderr, "strdup failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    return p;
}

int *safe_realloc(int *p, size_t newsize) {
    int *np = realloc(p, newsize);
    if (!np) {
        fprintf(stderr, "realloc failed: %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
    return np;
}
```

### Network Error Handling

```c
#include <curl/curl.h>
#include <openssl/ssl.h>
#include <string.h>

int handle_network_error(CURLcode res) {
    if (res != CURLE_OK) {
        fprintf(stderr, "curl error: %s (code=%d)\n",
                curl_easy_strerror(res), (int)res);
        return -1;
    }
    return 0;
}

void handle_ssl_error(int ret) {
    int sslerr = SSL_get_error(SSL_handle, ret);
    if (sslerr != SSL_ERROR_NONE) {
        fprintf(stderr, "SSL error: %s\n",
                ERR_error_string(ERR_get_error(), NULL));
    }
}
```

---

## Error Reporting Strategies

### 1. Return Codes

```c
int result = do_something();
if (result != 0) {
    fprintf(stderr, "do_something() failed: %s\n", strerror(errno));
    return EXIT_FAILURE;
}
```

### 2. Error Struct

```c
typedef struct {
    int code;
    const char *message;
    const char *file;
    int line;
} Error;

#define ERROR(code, msg) ((Error){.code = code, .message = msg, .file = __FILE__, .line = __LINE__})
```

### 3. Assert for Development

```c
#include <assert.h>

void process_data(int *data, size_t n) {
    assert(data != NULL);
    assert(n > 0);
    assert(n < 1000000);
}
```
