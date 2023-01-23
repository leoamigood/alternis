defmodule Alternis.Engines.DictionaryEngine.ImplTest do
  use Alternis.DataCase, async: true

  import Alternis.Factory

  alias Alternis.Engines.DictionaryEngine
  alias Alternis.Game.GameLanguage.English
  alias Alternis.Game.GameLanguage.Russian
  alias Alternis.Word

  import Hammox
  setup :verify_on_exit!

  describe "find_word/1" do
    setup do
      insert(:word, dictionary: insert(:dictionary, language: English), lemma: "secret")
      insert(:word, dictionary: insert(:dictionary, language: Russian), lemma: "секрет")

      :ok
    end

    test "finds word in dictionary" do
      assert %Word{lemma: "secret"} = DictionaryEngine.Impl.find_word("secret", English)
      refute DictionaryEngine.Impl.find_word("nonexistent", English)
    end

    test "finds word in dictionary in non english" do
      assert %Word{lemma: "секрет"} = DictionaryEngine.Impl.find_word("секрет", Russian)
    end

    test "finds word in dictionary case insensitive" do
      assert %Word{lemma: "secret"} = DictionaryEngine.Impl.find_word("Secret", English)
      assert %Word{lemma: "секрет"} = DictionaryEngine.Impl.find_word("Секрет", Russian)
    end
  end
end
