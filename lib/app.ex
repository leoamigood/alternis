defmodule Alternis.App do
  @moduledoc """
  This module keeps the contexts that define domains and business logic.
  """

  def domain_model do
    quote do
      use Ecto.Schema

      @type t :: %__MODULE__{}
    end
  end

  @doc """
  When used, dispatch to the appropriate schema
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
