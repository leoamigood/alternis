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
      english = insert(:dictionary, language: English)
      russian = insert(:dictionary, language: Russian)

      insert(:word, dictionary: english, lemma: "secret")
      insert(:word, dictionary: russian, lemma: "секрет")

      :ok
    end

    test "finds word in dictionary" do
      assert %Word{lemma: "secret"} = DictionaryEngine.Impl.find_word("secret")
      refute DictionaryEngine.Impl.find_word("nonexistent")
    end

    test "finds word in dictionary in non english" do
      assert %Word{lemma: "секрет"} = DictionaryEngine.Impl.find_word("секрет")
    end

    test "finds word in dictionary case insensitive" do
      assert %Word{lemma: "secret"} = DictionaryEngine.Impl.find_word("Secret")
      assert %Word{lemma: "секрет"} = DictionaryEngine.Impl.find_word("Секрет")
    end
  end
end
