defmodule MineSweep.UsersTest do
  use MineSweep.DataCase

  alias MineSweep.Users

  describe "credentials" do
    alias MineSweep.Users.Credential

    @valid_attrs %{password: "some password", username: "some username"}
    @update_attrs %{password: "some updated password", username: "some updated username"}
    @invalid_attrs %{password: nil, username: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_credential()

      credential
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Users.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Users.get_credential!(credential.id) == credential
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

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{} = credential} = Users.update_credential(credential, @update_attrs)
      assert credential.password == "some updated password"
      assert credential.username == "some updated username"
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_credential(credential, @invalid_attrs)
      assert credential == Users.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Users.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Users.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Users.change_credential(credential)
    end
  end
end
