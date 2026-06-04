defmodule Agora.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :rating, :integer, null: false
      add :body, :text
      add :listing_id, references(:listings, on_delete: :delete_all), null: false
      add :reviewer_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:listing_id])
    create index(:reviews, [:reviewer_id])
    create unique_index(:reviews, [:listing_id, :reviewer_id])
  end
end
