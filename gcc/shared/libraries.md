# GCC — Libraries Index

## Core System Libraries

| Library | Header | pkg-config | Purpose |
| ------- | ------ | ---------- | ------- |
| **libc** | `<stdlib.h>` | `libc` | C standard library |
| **libm** | `<math.h>` | `libc` | Math functions |
| **libpthread** | `<pthread.h>` | `libc` | POSIX threads |
| **libdl** | `<dlfcn.h>` | `libc` | Dynamic loading |
| **librt** | `<time.h>` | `libc` | Real-time |
| **libbsd** | `<bsd/string.h>` | `libbsd` | BSD extensions |

---

## String and Text Processing

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **glib** | `<glib.h>` | 2.78+ | GLib — core utility library (hash tables, lists, strings) |
| **oniguruma** | `<oniguruma.h>` | 6.9+ | Regular expressions |
| **pcre2** | `<pcre2.h>` | 10.42+ | Perl-compatible regex (PCRE2) |
| **libexpat** | `<expat.h>` | 2.5+ | XML parser |
| **libxml2** | `<libxml/parser.h>` | 2.12+ | Full XML processing |
| **libyaml** | `<yaml.h>` | 0.2+ | YAML parser |
| **cJSON** | `<cJSON.h>` | 1.7+ | Lightweight JSON parser |
| **jansson** | `<jansson.h>` | 2.14+ | JSON library (C) |

---

## Network and HTTP

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **libcurl** | `<curl/curl.h>` | 8.5+ | HTTP client, multi-protocol (HTTP/HTTPS/FTP/SMB) |
| **openssl** | `<openssl/ssl.h>` | 3.2+ | TLS/SSL, cryptographic functions |
| **mbedtls** | `mbedtls/ssl.h` | 3.6+ | TLS/SSL (lightweight, embedded) |
| **nghttp2** | `<nghttp2/nghttp2.h>` | 1.58+ | HTTP/2 library |
| **libuv** | `<uv.h>` | 1.48+ | Async I/O event loop |
| **libevent** | `<event2/event.h>` | 2.1+ | Event notification library |
| **ares** | `<ares.h>` | 1.28+ | Asynchronous DNS resolver |
| **c-ares** | `<ares.h>` | 1.28+ | Non-blocking DNS |

---

## Compression and Archives

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **zlib** | `<zlib.h>` | 1.3+ | DEFLATE compression |
| **libbz2** | `<bzlib.h>` | 1.0+ | Bzip2 compression |
| **lz4** | `<lz4.h>` | 1.9+ | Fast compression |
| **zstd** | `<zstd.h>` | 1.5+ | LZ77-based compression |
| **libpng** | `<png.h>` | 1.6+ | PNG image format |
| **libjpeg** | `<jpeglib.h>` | 9.0+ | JPEG image format |
| **libtiff** | `<tiffio.h>` | 4.5+ | TIFF image format |
| **libzip** | `<zip.h>` | 1.11+ | ZIP archive library |

---

## Database

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **sqlite3** | `<sqlite3.h>` | 3.44+ | Embedded SQL database |
| **hiredis** | `<hiredis/hiredis.h>` | 1.2+ | Redis client library |
| **pq** | `<libpq-fe.h>` | 16+ | PostgreSQL client library |
| **mysql** | `<mysql.h>` | 8.3+ | MySQL/MariaDB client |

---

## Cryptography and Security

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **openssl** | `<openssl/ssl.h>` | 3.2+ | TLS, SSL, HMAC, SHA, AES, RSA, ECC |
| **libsodium** | `<sodium.h>` | 1.0+ | Modern crypto (NaCl) |
| **GnuTLS** | `<gnutls/gnutls.h>` | 3.8+ | TLS implementation |
| **Nettle** | `<nettle/aes.h>` | 3.10+ | Lightweight crypto |
| **libgcrypt** | `<gcrypt.h>` | 1.11+ | General crypto library (GnuPG) |

---

## Logging

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **syslog** | `<syslog.h>` | — | System log (libc) |
| **syslog-ng** | `<liblogging-stdlog.h>` | 4.2+ | Advanced syslog |
| **log4c** | `<log4c.h>` | 1.2+ | log4j-style logging |
| **spdlog** | `<spdlog/spdlog.h>` | 1.14+ | Fast header-only logging (C++) |
| **liblog** | `<log/log.h>` | — | Lightweight logging |

---

## Configuration

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **gconf** | `<glib/gkeyfile.h>` | — | GLib keyfile config |
| **libconfig** | `<config.h>` | 1.7+ | Hierarchical config format |
| **inih** | `INIReader.h` | 58+ | Simple INI file reader (C++) |
| **cmocka** | `<cmocka.h>` | 1.1+ | Unit testing framework (also config) |

---

## Unit Testing

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **cmocka** | `<cmocka.h>` | 1.1+ | C unit testing framework |
| **check** | `<check.h>` | 0.15+ | Unit testing framework |
| **Unity** | `unity.h` | 3.5+ | Lightweight unit testing (header-only) |
| **CUT** | `<cutest.h>` | — | C unit testing |
| **Tap** | `<tap.h>` | — | Test Anything Protocol |

---

## Dynamic Loading

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **dl** | `<dlfcn.h>` | — | dlopen/dlsym/dlclose |
| **gmodule** | `<glib/gmodule.h>` | — | GLib modules |
| **libffi** | `<ffi.h>` | 3.4+ | Foreign function interface |

---

## Error Handling

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **glib** | `<glib.h>` | — | g_error, g_warning |
| **perror** | `<stdio.h>` | — | Standard C error printing |
| **strerror** | `<string.h>` | — | Standard C error strings |

---

## File I/O

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **glib** | `<glib.h>` | — | GIO — file I/O and streams |
| **libev** | `<ev.h>` | 4.3+ | Event loop (file descriptors) |
| **liburing** | `<liburing.h>` | 2.6+ | Linux io_uring interface |
| **mmap** | `<sys/mman.h>` | — | Memory-mapped I/O (libc) |

---

## Serialization

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **cJSON** | `<cJSON.h>` | 1.7+ | JSON (C) |
| **jansson** | `<jansson.h>` | 2.14+ | JSON (C, with custom types) |
| **msgpack** | `<msgpack.h>` | 6.0+ | MessagePack serialization |
| **cbor** | `<cbor.h>` | 0.11+ | CBOR serialization |
| **flatbuffers** | `<flatbuffers/flatbuffers.h>` | 24+ | FlatBuffers (C/C++) |
| **protobuf-c** | `<protobuf-c/protobuf-c.h>` | 1.5+ | Protocol Buffers (C) |

---

## XML and Markup

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **libxml2** | `<libxml/parser.h>` | 2.12+ | XML parsing, XSLT, XPath |
| **libexpat** | `<expat.h>` | 2.5+ | Expat XML parser |
| **libyaml** | `<yaml.h>` | 0.2+ | YAML parsing |

---

## HTTP and Web

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **libcurl** | `<curl/curl.h>` | 8.5+ | HTTP client (multi-protocol) |
| **nghttp2** | `<nghttp2/nghttp2.h>` | 1.58+ | HTTP/2 |
| **libmicrohttpd** | `<microhttpd.h>` | 0.9+ | HTTP server library |
| **mongoose** | `mongoose.h` | 7.15+ | Embedded web server (header-only) |

---

## Concurrent Programming

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **libpthread** | `<pthread.h>` | — | POSIX threads (libc) |
| **tbb** | `<tbb/tbb.h>` | 2022+ | Threading Building Blocks (Intel) |
| **coro** | `<coro/coro.h>` | 2+ | Lightweight C coroutines (header-only) |
| **libco** | `co.h` | — | Coroutine library |

---

## Logging and Tracing

| Library | Header | Version | Purpose |
| ------- | ------ | ------- | ------- |
| **spdlog** | `<spdlog/spdlog.h>` | 1.14+ | Fast C++ logging (header-only) |
| **glog** | `<glog/logging.h>` | 0.6+ | Google logging library |
| **libfmt** | `<fmt/core.h>` | 10+ | Fast format library (C++) |
| **liblog4c** | `<log4c.h>` | 1.2+ | log4j-style C logging |

---

## Build-Time Library Discovery

### pkg-config Usage

```bash
# Find all installed libraries
pkg-config --list-all

# Get compilation flags and library flags
pkg-config --cflags openssl
pkg-config --libs openssl
pkg-config --cflags --libs openssl

# Version checking
pkg-config --modversion openssl
pkg-config --atleast-version=3.0 openssl

# Multiple libraries
pkg-config --cflags --libs openssl zlib libcurl

# Check existence
pkg-config --exists openssl && echo "found"

# Use in Makefile
PKG_CONFIG := pkg-config
OPENSSL_CFLAGS := $(shell $(PKG_CONFIG) --cflags openssl)
OPENSSL_LIBS := $(shell $(PKG_CONFIG) --libs openssl)
```

### CMake find_package

```cmake
# Standard packages (built-in)
find_package(Threads REQUIRED)
find_package(ZLIB REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(OpenMP REQUIRED)
find_package(SQLite3 REQUIRED)
find_package(PkgConfig REQUIRED)

# Use pkg-config for external libraries
pkg_check_modules(CURL REQUIRED libcurl)
pkg_check_modules(YAML REQUIRED libyaml)
pkg_check_modules(BZ2 REQUIRED bz2)
pkg_check_modules(LZ4 REQUIRED lz4)
pkg_check_modules(ZSTD REQUIRED libzstd)
pkg_check_modules(HIREDIS REQUIRED hiredis)
pkg_check_modules(JANSSON REQUIRED jansson)
pkg_check_modules(EXPAT REQUIRED expat)
pkg_check_modules(NGHTTP2 REQUIRED nghttp2)
pkg_check_modules(CMOCKA REQUIRED cmocka)
pkg_check_modules(GCRYPT REQUIRED libgcrypt)
pkg_check_modules(SODIUM REQUIRED libsodium)
pkg_check_modules(ARES REQUIRED c-ares)
```

---

## Library Selection Guide

### When to Choose Which Library

| Need | Recommended | Reason |
| ---- | ----------- | ------ |
| HTTP client | **libcurl** | Multi-protocol, widely used, well-maintained |
| TLS/SSL | **OpenSSL** | Industry standard, extensive crypto |
| JSON | **cJSON** | Lightweight, single-file, simple API |
| XML | **libxml2** | Full-featured, XPath/XSLT support |
| Embedded DB | **sqlite3** | Zero-config, single file, ACID |
| HTTP server | **libmicrohttpd** | Lightweight, non-blocking |
| Compression | **zlib** | DEFLATE standard, widely available |
| Fast compression | **zstd** or **lz4** | zstd for balance, lz4 for speed |
| Regex | **pcre2** | PCRE2, Perl-compatible |
| YAML | **libyaml** | Fast, lightweight YAML parser |
| Redis client | **hiredis** | Official Redis client for C |
| PostgreSQL | **libpq** | Official PostgreSQL client |
| Config files | **libconfig** | Hierarchical format, simple API |
| HTTP/2 | **nghttp2** | Full HTTP/2 implementation |
| Event loop | **libuv** | Cross-platform, async I/O |
| Unit testing | **cmocka** or **check** | cmocka for simplicity, check for coverage |
| Logging | **spdlog** (C++) or **log4c** (C) | spdlog for speed, log4c for features |
| JSON (advanced) | **jansson** | Custom types, serialization |
| MessagePack | **msgpack** | Compact binary JSON alternative |
| Protocol buffers | **protobuf-c** | C version of Google Protocol Buffers |
| Flat files | **flatbuffers** | Zero-copy deserialization |
