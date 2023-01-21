Hammox.defmock(Alternis.Engines.GameEngine.Mock, for: Alternis.Engines.GameEngine)
Hammox.defmock(Alternis.Engines.MatchEngine.Mock, for: Alternis.Engines.MatchEngine)
Hammox.defmock(Alternis.Engines.DictionaryEngine.Mock, for: Alternis.Engines.DictionaryEngine)

defmodule Mock do
  @moduledoc false

  def allow_to_call_impl(module, method, arity, suffix \\ Impl) do
    impl = Function.capture(Module.concat(module, suffix), method, arity)
    Hammox.expect(module.impl(), method, impl)
  end
end
