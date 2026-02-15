defmodule CloseTheLoop.Messaging.PhoneTest do
  use ExUnit.Case, async: true

  alias CloseTheLoop.Messaging.Phone

  describe "normalize_e164/1" do
    test "returns nil for nil/blank" do
      assert {:ok, nil} = Phone.normalize_e164(nil)
      assert {:ok, nil} = Phone.normalize_e164("")
      assert {:ok, nil} = Phone.normalize_e164("   ")
    end

    test "accepts E.164 with leading +" do
      assert {:ok, "+15555550100"} = Phone.normalize_e164("+15555550100")
      assert {:ok, "+442079460958"} = Phone.normalize_e164("+44 20 7946 0958")
    end

    test "accepts US/Canada 10-digit numbers and assumes +1" do
      assert {:ok, "+14254207179"} = Phone.normalize_e164("425.420.7179")
      assert {:ok, "+14254207179"} = Phone.normalize_e164("(425) 420-7179")
      assert {:ok, "+14254207179"} = Phone.normalize_e164("425 420 7179")
    end

    test "accepts US/Canada numbers with leading 1" do
      assert {:ok, "+14254207179"} = Phone.normalize_e164("1-425-420-7179")
    end

    test "rejects invalid input" do
      assert {:error, msg} = Phone.normalize_e164("555-555-010")
      assert is_binary(msg)
    end
  end
end
