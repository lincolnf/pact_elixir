defmodule PactElixir.BundlexProject do
  use Bundlex.Project

  def project do
    [
      natives: natives()
    ]
  end


  defp natives() do
    [
      native_mock_server: [
        sources: ["native_mock_server.c"],
        deps: [unifex: :unifex],
        interface: [:nif, :cnode],
        preprocessor: Unifex
      ]
    ]
  end
end

