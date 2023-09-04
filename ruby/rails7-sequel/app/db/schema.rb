Sequel.migration do
  change do
    create_table(:schema_info) do
      column :version, "integer", :default=>0, :null=>false
    end
    
    create_table(:users) do
      primary_key :id
      column :name, "text", :null=>false
      column :email, "text", :null=>false
    end
  end
end
Sequel.migration do
  change do
    self << "SET search_path TO \"$user\", public"
    self << "INSERT INTO \"schema_info\" (\"version\") VALUES (1)"
  end
end
