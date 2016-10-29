# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: protocol.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "SaveRequest" do
    optional :bucket, :string, 1
    optional :key, :string, 2
    optional :contentType, :string, 3
    optional :content, :bytes, 4
  end
  add_message "SaveResponse" do
    optional :status, :enum, 1, "Status"
    optional :bucket, :string, 2
    optional :key, :string, 3
  end
  add_message "GetRequest" do
    optional :bucket, :string, 1
    optional :key, :string, 2
  end
  add_message "GetResponse" do
    optional :status, :enum, 1, "Status"
    optional :bucket, :string, 2
    optional :key, :string, 3
    optional :contentType, :string, 4
    optional :content, :bytes, 5
  end
  add_message "DeleteRequest" do
    optional :bucket, :string, 1
    optional :key, :string, 2
  end
  add_message "DeleteResponse" do
    optional :status, :enum, 1, "Status"
    optional :bucket, :string, 2
    optional :key, :string, 3
  end
  add_enum "Status" do
    value :Ok, 0
    value :NotFound, 1
  end
end

SaveRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("SaveRequest").msgclass
SaveResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("SaveResponse").msgclass
GetRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("GetRequest").msgclass
GetResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("GetResponse").msgclass
DeleteRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("DeleteRequest").msgclass
DeleteResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("DeleteResponse").msgclass
Status = Google::Protobuf::DescriptorPool.generated_pool.lookup("Status").enummodule