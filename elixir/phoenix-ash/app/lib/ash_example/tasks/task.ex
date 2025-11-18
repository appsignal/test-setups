defmodule AshExample.Tasks.Task do
  use Ash.Resource,
    domain: AshExample.Tasks,
    data_layer: Ash.DataLayer.Ets

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  attributes do
    uuid_primary_key :id

    attribute :tenant_id, :string do
      allow_nil? false
      public? true
    end

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :completed, :boolean do
      default false
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:title, :description]
    end

    update :update do
      accept [:title, :description, :completed]
    end

    update :complete do
      accept []
      change set_attribute(:completed, true)
    end
  end

  code_interface do
    define :create
    define :read
    define :update
    define :complete
    define :destroy
  end
end
