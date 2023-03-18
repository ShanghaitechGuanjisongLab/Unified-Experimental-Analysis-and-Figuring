classdef UniExpException<MATLAB.Lang.IEnumerableException
	enumeration
		Wrong_number_of_arguments
		Image_size_does_not_match
		DateTime_primary_key_has_duplicate_values
		Some_commits_are_missing_UID_definitions
		Inconsistent_cells_per_line
		Wrong_array_size
		NaN_appears_after_normalization
		No_data_matching_the_filter_criteria
		No_trials_identified
		Undefined_UID_found
		Table_is_missing_key_column
		Table_is_missing_required_column
		Unknown_normalize_algorithm
		Video_and_ROI_file_numbers_do_not_match
		More_than_one_SplitType_Cell_was_found_in_Block
		The_Block_for_the_specified_Design_could_not_be_found
		The_MovingSamples_extension_must_be_oir_or_tif
		Unknown_accumulate_method
		Trials_are_inconsistent
		The_Trials_table_is_missing_the_Stimulus_column
		Normalization_failed
		The_number_of_MovingRois_and_MovingSamples_does_not_match
		The_number_of_split_trials_does_not_match_the_existing_record
		Table_not_found_in_input
		Invalid_Flag
		The_first_two_dimensions_of_Points_and_LineColors_are_different
		GroupIndex_is_not_continuous
		The_number_of_LineColors_is_less_than_that_of_lines
		TransMatrix_is_much_less_than_OirPaths
		TransMatrix_is_more_than_OirPaths
		ZLayers_of_the_moving_ROI_and_file_do_not_match
		Must_specify_CacheDirectory_if_BaseRegisterToCache
		PathArray_must_have_2_or_3_columns
		Mean_Tiff_exist_under_OutputDirectory
		Std_Tiff_exist_under_OutputDirectory
		Lengths_of_TrialSignals_within_the_query_group_is_different
		Numbers_of_fixed_and_moving_ROIs_vary
		Column_not_found
		Invalid_Parallel_option
	end
end