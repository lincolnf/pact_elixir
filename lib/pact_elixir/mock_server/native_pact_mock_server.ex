defmodule PactElixir.NativeMockServer do
  @moduledoc """
  Adapter for the wrapped rust [pact mock server](https://github.com/pact-foundation/pact-reference).
  Functions in this file are replaced by Rustler with their Rust calling
  counterpart. See native/pactmockserver/src/lib.rs for the concrete Rust
  implementation.
  This file is excluded from the coverage tool.
  """
  use Unifex.Loader
end

