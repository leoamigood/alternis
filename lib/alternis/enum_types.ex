defmodule Alternis.EnumTypes do
  @moduledoc "Enum definitions macro"

  defmacro __using__(_) do
    quote do
      use EnumType

      defenum GameStatus do
        value(Created, "created")
        value(Running, "running")
        value(Finished, "finished")
        value(Aborted, "aborted")

        default(Created)
      end
    end
  end
end
