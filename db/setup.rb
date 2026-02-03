require "sequel"

DB = Sequel.sqlite("db/app.sqlite3")

DB.create_table? :users do
  primary_key :id
  String :email, null: false, unique: true
  Integer :free_count, null: false, default: 0
  String :stripe_customer_id
  String :subscription_status, null: false, default: "inactive"
  DateTime :created_at
end

DB.create_table? :login_codes do
  primary_key :id
  String :email, null: false
  String :code_hash, null: false
  DateTime :expires_at, null: false
  DateTime :used_at
  DateTime :created_at
end

puts "DB ready"
