class AllowNullMetadataInActiveStorageBlobs < ActiveRecord::Migration[8.0]
  def change
    change_column_null :active_storage_blobs, :metadata, true
  end
end
