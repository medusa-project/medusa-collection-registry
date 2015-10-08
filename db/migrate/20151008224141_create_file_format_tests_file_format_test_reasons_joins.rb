class CreateFileFormatTestsFileFormatTestReasonsJoins < ActiveRecord::Migration
  def change
    create_table :file_format_tests_file_format_test_reasons_joins do |t|
      t.references :file_format_test, foreign_key: true
      t.references :file_format_test_reason, foreign_key: true
    end
    add_index :file_format_tests_file_format_test_reasons_joins, :file_format_test_reason_id,
              name: :fft_fftr_joins_fftr_id_index
    add_index :file_format_tests_file_format_test_reasons_joins, [:file_format_test_id, :file_format_test_reason_id],
        unique: true, name: :fft_fftr_joins_unique_pairs
  end
end
