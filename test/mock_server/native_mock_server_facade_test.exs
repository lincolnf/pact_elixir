# TODO: This test has a broken usage of ports.
defmodule PactElixir.NativeTest do
  use ExUnit.Case
  alias PactElixir.NativeMockServer

  @pact """
  {
        "provider": {
          "name": "test_provider"
        },
        "consumer": {
          "name": "test_consumer"
        },
        "interactions": [
          {
            "providerState": "test state",
            "description": "test interaction",
            "request": {
              "method": "GET",
              "path": "/call_me"
            },
            "response": {
              "status": 200,
              "body": "Stop calling me"
            }
          }
        ],
        "metadata": {
          "pact-specification": {
            "version": "2.0.0"
          }
        }
      }
  """
  @port 50_823

  describe "create_mock_server" do
    test "creates a mock server and returns its port" do
      assert {:ok, @port} == NativeMockServer.create_mock_server(@pact, @port)
      assert "Stop calling me" == get_request("/call_me").body
      NativeMockServer.cleanup_mock_server(@port)
    end

    test "fails if mock server could not start due to broken json" do
      broken_json = "broken{}json"

      assert {:error, :invalid_pact_json} =
               NativeMockServer.create_mock_server(broken_json, @port)
    end

    # TODO: Find a way to trigger this error
    # test "returns error if mock server could not start because of some general error" do
    #   assert {:error, :mock_server_failed_to_start} = NativeMockServer.create_mock_server(@pact, 22)

    #   NativeMockServer.cleanup_mock_server(@port)
    # end
  end

  describe "mock_server_mismatches" do
    test "returns mismatches json when no requests were made" do
      port = 50_824
      NativeMockServer.create_mock_server(@pact, port)

      assert {:ok, mismatches_json_string} = NativeMockServer.mock_server_mismatches(port)

      assert String.ends_with?(mismatches_json_string, "}]")
      NativeMockServer.cleanup_mock_server(port)
    end
  end

  describe "matched" do
    test "returns false if none of expected requests were made" do
      port = 50_828
      NativeMockServer.create_mock_server(@pact, port)
      assert {:ok, false} = NativeMockServer.mock_server_matched(port)
      NativeMockServer.cleanup_mock_server(port)
    end
  end

  describe "write_pact_file" do
    test "writes pact file" do
      {:ok, dir_path} = Temp.mkdir("NativeTest")
      port = 50_825
      NativeMockServer.create_mock_server(@pact, port)
      assert {:ok} = NativeMockServer.write_pact_file(port, dir_path)
      NativeMockServer.cleanup_mock_server(port)
    end

    test "returns error if there is no mock server for port" do
      {:ok, dir_path} = Temp.mkdir("NativeTest")

      assert {:error, :no_mock_server_running_on_port} =
               NativeMockServer.write_pact_file(@port - 1000, dir_path)
    end

    test "returns error if io could not complete" do
      port = 50_826
      NativeMockServer.create_mock_server(@pact, port)

      assert {:error, :io_error} =
               NativeMockServer.write_pact_file(port, "/not/existing/path")

      NativeMockServer.cleanup_mock_server(port)
    end
  end

  describe "cleanup_mock_server" do
    test "returns true" do
      port = 50_827
      NativeMockServer.create_mock_server(@pact, port)
      assert {:ok} == NativeMockServer.cleanup_mock_server(port)
    end
  end

  def get_request(path) do
    %HTTPoison.Response{} = HTTPoison.get!("http://localhost:#{@port}#{path}")
  end
end
