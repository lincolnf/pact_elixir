#include "native_mock_server.h"
#include <stdio.h>
#include <dlfcn.h>
#include <stdbool.h>

int lib_initied = 0;
void* lib_handle;

typedef int32_t (*lib_create_mock_server)(const char *, const char*);
typedef bool (*lib_mock_server_matched)(int32_t);
typedef bool (*lib_cleanup_mock_server)(int32_t);
typedef char* (*lib_mock_server_mismatches)(int32_t);
typedef int32_t (*lib_write_pact_file)(int32_t, const char *, int32_t);

lib_create_mock_server pactffi_create_mock_server;
lib_mock_server_matched pactffi_mock_server_matched;
lib_cleanup_mock_server pactffi_cleanup_mock_server;
lib_mock_server_mismatches pactffi_mock_server_mismatches;
lib_write_pact_file pactffi_write_pact_file;


void init_libpact_ffi() {
  if(lib_initied != 0) {
    return;
  }

  lib_handle = dlopen("libpact_ffi.dylib", RTLD_LOCAL|RTLD_LAZY);

 if(lib_handle) {
    pactffi_create_mock_server = dlsym(lib_handle, "pactffi_create_mock_server");
    pactffi_mock_server_matched = dlsym(lib_handle, "pactffi_mock_server_matched");
    pactffi_cleanup_mock_server = dlsym(lib_handle, "pactffi_cleanup_mock_server");
    pactffi_mock_server_mismatches = dlsym(lib_handle, "pactffi_mock_server_mismatches");
    pactffi_write_pact_file = dlsym(lib_handle, "pactffi_write_pact_file");
    lib_initied = 1;
 } else {
    printf("Failed to open shared library %s\n", dlerror());
    exit(0);
 }
}

UNIFEX_TERM create_mock_server(UnifexEnv *env, char * pact_json, unsigned port) {
  init_libpact_ffi();
  char host[1000];
  snprintf(host, 999, "127.0.0.1:%d", port);

  printf("starting mocker server on %s\n", host); 

  int32_t result = pactffi_create_mock_server(pact_json, host);

  if(result < 0) {
    printf("Failed to create mock server, code %d\n", result);

    if(result == -1) { return create_mock_server_result_error_null_ptr(env); }
    if(result == -2) { return create_mock_server_result_error_invalid_pact_json(env); }
    if(result == -3) { return create_mock_server_result_error_server_not_started(env); }
    if(result == -4) { return create_mock_server_result_error_panic(env); }
    if(result == -5) { return create_mock_server_result_error_address_invalid(env); }
    if(result == -6) { return create_mock_server_result_error_tls_config(env); }


    return create_mock_server_result_error_unknown(env, result);
  }

  return create_mock_server_result_ok(env, result);
}

UNIFEX_TERM cleanup_mock_server(UnifexEnv *env, unsigned port) {
  init_libpact_ffi();
  if(!pactffi_cleanup_mock_server(port)) {
    return cleanup_mock_server_result_error(env);
  }
  return cleanup_mock_server_result_ok(env);
}

UNIFEX_TERM mock_server_matched(UnifexEnv *env, unsigned port) {
  init_libpact_ffi();
  bool result = pactffi_mock_server_matched(port);
  printf("matched result %d", result);
  return mock_server_matched_result_ok(env, result);
}

UNIFEX_TERM mock_server_mismatches(UnifexEnv *env, unsigned port) {
  init_libpact_ffi();
  return mock_server_mismatches_result_ok(
     env, 
     pactffi_mock_server_mismatches(port)
  );
}

UNIFEX_TERM write_pact_file(UnifexEnv *env, unsigned port, char * path) {
  init_libpact_ffi();
  int32_t result = pactffi_write_pact_file(port, path, 0);
  if(result > 0) {
    if(result == 1) { return write_pact_file_result_error_general(env); }
    if(result == 2) { return write_pact_file_result_error_io_error(env); }
    if(result == 3) { return write_pact_file_result_error_no_mock_server_running_on_port(env); }

    return write_pact_file_result_error_unknown(env, result);
  }
  return write_pact_file_result_ok(env);
}
