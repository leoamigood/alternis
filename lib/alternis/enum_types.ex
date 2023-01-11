defmodule Alternis.EnumTypes do
  @moduledoc "Enum definitions macro"

  defmacro __using__(_) do
    quote do
      use EnumType

      defenum GameState do
        value(Created, "created")
        value(Running, "running")
        value(Finished, "finished")
        value(Aborted, "aborted")

        default(Created)
      end

      defenum GameSource do
        value(Web, "web")
        value(Telegram, "telegram")

        default(Web)
      end

      defenum GameAction do
        value(GuessAction, "guess")
        value(AbortAction, "abort")
      end
    end
  end
end
