# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:lfg) do
      String :discord_id, null: false, index: true
      String :channel_id, null: false, index: true
      Date :date, null: false, index: true
      primary_key %i[discord_id channel_id date], name: :lfg_pk
    end
  end
end
