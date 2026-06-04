defmodule Agora.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string, null: false, default: "pending"
      add :stripe_session_id, :string
      add :amount_cents, :integer, null: false
      add :listing_id, references(:listings, on_delete: :restrict), null: false
      add :buyer_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:listing_id])
    create index(:orders, [:buyer_id])
    create index(:orders, [:stripe_session_id])
  end
end
