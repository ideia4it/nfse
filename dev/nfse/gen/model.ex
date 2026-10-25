defmodule Nfse.Gen.Model do
  @moduledoc false

  defstruct complex: %{}, simple: %{}, roots: %{}, files: %{}

  defmodule Attribute do
    @moduledoc false
    @enforce_keys [:name, :type, :required?]
    defstruct [:name, :type, :required?]
  end

  defmodule SimpleType do
    @moduledoc false
    @enforce_keys [:name, :base, :facets]
    defstruct [:name, :base, :doc, :facets]
  end

  defmodule Element do
    @moduledoc false
    @enforce_keys [:name, :type, :min, :max]
    defstruct [
      :name,
      :type,
      :min,
      :max,
      :doc,
      :anonymous_simple,
      :anonymous_complex,
      signature?: false
    ]
  end

  defmodule ComplexType do
    @moduledoc false
    @enforce_keys [:name, :file, :particles, :attributes]
    defstruct [:name, :doc, :file, :particles, :attributes]
  end
end
