defmodule MineSweep.UsersTest do
  use MineSweep.DataCase

  alias MineSweep.Users

  describe "credentials" do
    alias MineSweep.Users.Credential

    @valid_attrs %{password: "some password", username: "some username"}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_credential()

      credential
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Users.create_credential(@valid_attrs)
      assert Bcrypt.verify_pass "some password", credential.password
      assert credential.username == "some username"
    end

    test "create_credential/1 with replicate username returns error changeset" do
      assert {:ok, %Credential{}} = Users.create_credential(@valid_attrs)
      assert {:error, %Ecto.Changeset{valid?: false}} = Users.create_credential(@valid_attrs)
    end
  end

  describe "records" do
    alias MineSweep.Users.{Record, Credential}

    @valid_attrs %{level: "hard", record: 42}
    @invalid_attrs_list [%{level: nil, record: nil},
                         %{level: "unknown" , record: 1},
                         %{level: "easy", record: 0},]

    def record_fixture() do

      creds = [%{username: "a", password: "a"},
               %{username: "b", password: "b"}]

      Enum.reduce(creds, [], fn cred, acc ->
        {:ok, c} = Users.create_credential(cred)
        [c|acc]
      end)
    end

    test "create_record/1 with valid data creates a record" do
      [_, cred2] = record_fixture()

      assert {:ok, %Record{} = record} = Users.create_record(cred2, @valid_attrs)
      assert record.level == "hard"
      assert record.record == 42
    end

    test "create_record/1 with invalid data returns error changeset" do
      [_, cred2] = record_fixture()
      for invalid_attrs <- @invalid_attrs_list do
        assert {:error, %Ecto.Changeset{}} = Users.create_record(cred2, invalid_attrs)
      end
    end

    test "list_best_records_by_username/2 returns the given user's first n best records of each level" do
      [cred1, _] = record_fixture()

      records =
        [{11, "easy"},
         {8, "easy"},
         {12, "easy"},
         {43, "medium"},
         {35, "medium"},
         {38, "medium"},
         {138, "hard"},
         {88, "hard"},
         {159, "hard"},
        ]
      for {r, l} <- records do
        assert {:ok, %Record{}} = Users.create_record(cred1, %{record: r, level: l})
      end

      assert %{"easy" => easy, "medium" => medium, "hard" => hard} =
        Users.list_best_records_by_username(cred1.username, 2)
        |> Enum.group_by(&Map.get(&1, :level))
      assert 2 == easy |> length
      assert 2 == hard |> length
      assert 2 == medium |> length
      assert %{record: 8} = easy |> List.first
      assert %{record: 35} = medium |> List.first
      assert %{record: 88} = hard |> List.first
    end

    test "list_latest_records_by_username/2 returns the given user's first n latest records of each level" do
      [cred1, _] = record_fixture()

      records =
        [{11, "easy"},
         {8, "easy"},
         {12, "easy"},
         {43, "medium"},
         {35, "medium"},
         {38, "medium"},
         {138, "hard"},
         {88, "hard"},
         {159, "hard"},
        ]
      Enum.each records, fn {r, l} ->
        assert {:ok, %Record{}} = Users.create_record(cred1, %{record: r, level: l})
        :timer.sleep 1000
      end

      assert %{"easy" => easy, "medium" => medium, "hard" => hard} =
        Users.list_latest_records_by_username(cred1.username, 2)
        |> Enum.group_by(&Map.get(&1, :level))
      assert 2 == hard |> length
      assert 2 == easy |> length
      assert 2 == hard |> length
      assert 2 == medium |> length
      assert %{record: 12} = easy |> List.first
      assert %{record: 38} = medium |> List.first
      assert %{record: 159} = hard |> List.first
    end
  end
end
