srcdir = '/home/redondo/essais/DATTES_test_data/0_original_data/test_metadata_collector';

csv_list = lsFiles(srcdir,'.csv');

[metadata, meta_list,errors] = cellfun(@metadata_collector,csv_list,'UniformOutput',false);