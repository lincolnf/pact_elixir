module PactElixir.NativeMockServer

interface [NIF, CNode]

spec create_mock_server(pact_json :: string, port :: unsigned) :: 
  {:ok :: label, port :: unsigned}
  | {:error :: label, :null_ptr :: label}
  | {:error :: label, :invalid_pact_json :: label}
  | {:error :: label, :server_not_started :: label}
  | {:error :: label, :panic :: label}
  | {:error :: label, :address_invalid :: label}
  | {:error :: label, :tls_config :: label}
  | {:error :: label, :unknown :: label, code :: int}

spec write_pact_file(port :: unsigned, path :: string) :: 
  {:ok :: label}
  | {:error :: label, :general :: label}
  | {:error :: label, :io_error :: label}
  | {:error :: label, :no_mock_server_running_on_port :: label}
  | {:error :: label, :unknown :: label, code :: int}

spec cleanup_mock_server(port :: unsigned) :: 
  {:ok :: label}
  | {:error :: label}

spec mock_server_mismatches(port :: unsigned) :: {:ok :: label, mismatch :: string}

spec mock_server_matched(port :: unsigned) :: 
  {:ok :: label, all_matched :: bool}

