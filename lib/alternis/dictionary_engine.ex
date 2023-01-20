defmodule Alternis.Engines.DictionaryEngine do
  @moduledoc "Language corpus (dictionary) engine"

  alias Ecto.Changeset

  @implementation Application.compile_env!(:alternis, :dictionary_engine)
  def impl, do: @implementation

  @callback validate(Changeset.t(), atom) :: Changeset.t()
end
