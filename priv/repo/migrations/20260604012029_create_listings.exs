defmodule Agora.Repo.Migrations.CreateListings do
  use Ecto.Migration

  def change do
    create table(:listings) do
      add :title, :string, null: false
      add :description, :text
      add :price_cents, :integer, null: false
      add :status, :string, null: false, default: "draft"
      add :category_id, references(:categories, on_delete: :restrict), null: false
      add :seller_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:listings, [:category_id])
    create index(:listings, [:seller_id])
    create index(:listings, [:status])
  end
end
