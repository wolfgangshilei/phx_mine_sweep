defmodule MineSweep.UsersTest do
  use MineSweep.DataCase

  alias MineSweep.Users

  describe "credentials" do
    alias MineSweep.Users.Credential

    @valid_attrs %{password: "some_password", username: "some_username"}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_credential()

      credential
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Users.create_credential(@valid_attrs)
      assert Bcrypt.verify_pass "some_password", credential.password
      assert credential.username == "some_username"
    end

    test "create_credential/1 with replicate username returns error changeset" do
      assert {:ok, %Credential{}} = Users.create_credential(@valid_attrs)
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} = Users.create_credential(@valid_attrs)
      assert {"has already been taken", [
               constraint: :unique,
               constraint_name: "credentials_username_index"
             ]} =  Keyword.get(errors, :username)
    end

    test "create_credential/1 with missing username returns error changeset" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
        Users.create_credential(Map.delete(@valid_attrs, :username))
      assert {"can't be blank", [validation: :required]} =  Keyword.get(errors, :username)
    end

    test "create_credential/1 with missing password returns error changeset" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
        Users.create_credential(%{@valid_attrs | password: nil})
      assert {"can't be blank", [validation: :required]} =  Keyword.get(errors, :password)
    end

    test "create_credential/1 with username is empty string" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
        Users.create_credential(%{@valid_attrs | username: ""})

      assert {"can't be blank", [validation: :required]} =  Keyword.get(errors, :username)
    end

    test "create_credential/1 with password too short" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
        Users.create_credential(%{@valid_attrs | password: "111"})

      assert {"should be at least %{count} character(s)",
              [count: 6, validation: :length, kind: :min]} =  Keyword.get(errors, :password)
    end

    test "create_credential/1 with username and password with wrong format" do
      assert {:error, %Ecto.Changeset{valid?: false, errors: errors}} =
        Users.create_credential(%{@valid_attrs | password: "select a", username: "<script/>"})

      assert {"should only contain letters, digits and characters in @.#_!$%", [validation: :format]} =
        Keyword.get(errors, :password)

      assert {"should only contain letters, digits and characters in @.#_", [validation: :format]} =
        Keyword.get(errors, :username)
    end

    test "authenticate_username_and_password/1 returns ok" do
      assert {:ok, cred = %Credential{}} = Users.create_credential(@valid_attrs)
      assert {:ok, ^cred} = Users.authenticate_username_and_password(@valid_attrs)
    end

    test "authenticate_username_and_password/1 with wrong password" do
      assert {:ok, cred = %Credential{}} = Users.create_credential(@valid_attrs)
      assert {:error, :wrong_username_or_password} = Users.authenticate_username_and_password(%{@valid_attrs | password: "wrongPassword"})
    end

    test "authenticate_username_and_password/1 with non-existing user" do
      assert {:ok, cred = %Credential{}} = Users.create_credential(@valid_attrs)
      assert {:error, :wrong_username_or_password} = Users.authenticate_username_and_password(%{@valid_attrs | username: "unknown_user"})
    end

    test "authenticate_username_and_password/1 with username and password not provided" do
      assert {:ok, cred = %Credential{}} = Users.create_credential(@valid_attrs)
      assert {:error, %Ecto.Changeset{valid?: false}} = Users.authenticate_username_and_password(%{password: nil, username: nil})
    end

  end

  describe "records" do
    alias MineSweep.Users.{Record, Credential}

    @valid_attrs %{level: "hard", record: 42}
    @invalid_attrs_list [%{level: nil, record: nil},
                         %{level: "unknown" , record: 1},
                         %{level: "easy", record: 0},]

    def record_fixture() do

      creds = [%{username: "abc", password: "111111"},
               %{username: "efg", password: "111111"}]

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
        |> IO.inspect
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
