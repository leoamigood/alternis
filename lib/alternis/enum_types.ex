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
        value(Expired, "expired")

        default(Created)
      end

      defenum GameSource do
        value(Web, "web")
        value(Telegram, "telegram")

        default(Web)
      end

      defenum GameLanguage do
        value(Unknown, "unknown")
        value(English, "english")
        value(Russian, "russian")

        default(Unknown)
      end
    end
  end
end
