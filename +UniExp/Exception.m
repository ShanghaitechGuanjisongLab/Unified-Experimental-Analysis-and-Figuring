classdef Exception<MATLAB.Lang.IEnumerableException
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
		Moving_image_is_a_video
		Found_an_empty_signal
		Struct_cannot_be_parsed_to_DataSet
		QueryTable_contains_both_GroupIndex_and_GroupName
		Empty_group
		Number_of_trials_inconsistent_with_EventLog
		Function_deprecated
		CellUIDs_differ_among_groups
		Numbers_of_cells_differ_among_groups
		Anonymous_groups_must_be_referenced_by_numerical_indices
		Failed_to_parse_argument
		Point_coordinates_must_have_2_or_3_dimensions
		Unexpected_EventLogCheckLevel_value
		No_data_found_in_group
		EventLog_has_no_Event_columns
		Specified_BlockUID_does_not_exist_in_the_Blocks_table
		Specified_TrialIndex_already_exists_in_the_specified_Block
		No_signal_to_split
		Too_many_trials_or_broken_EventLog
		Unexpected_trial_stimulus
		Cell_signals_vary_in_length
		TrialRI_could_not_be_calculated_for_Trials_without_Stimulus
		DataSet_is_missing_TrialSignals
		Scattered_light_correction_produces_negative_measurements
		Parameter_C_must_be_specified_for_a_multichannel_TIFF
		Parameter_Z_must_be_specified_for_a_multi_Z_TIFF
		Window_Center_or_ROI_must_be_specified
		Window_Size_or_ROI_must_be_specified
		Window_Size_larger_than_Tiff_size
		Invalid_ShowSeconds_Location
		Output_file_must_specify_FrameRate_or_ShowSeconds
		ShowSeconds_Size_or_ROI_must_be_specified
		Invalid_ZeroPoint
		Invalid_number
		No_slices_input
		Unexpected_subsref_type
		Required_slice_empty
		Mat_load_failed
		Coronal_and_Sagittal_have_no_overlap
		Input_slices_does_not_sandwich_the_target_layer
		Ambiguous_copy_source
		Unexpected_argument_type
		CacheDirectory_not_empty
		Tolerance_must_be_less_than_number_of_trials
		Some_trials_did_not_record_a_valid_CD2
		CD2_of_specified_trials_is_not_equal_in_length
		No_need_to_replenish
		Cannot_ANOVA_on_only_one_group
		Specified_duplicate_BlockUID
		Specified_duplicate_BlockIndex_and_DateTime
		Must_specify_BlockIndex
		Specified_DateTime_does_not_exist
		Unexpected_LogLevel
		Unexpected_file_extension
		Failed_to_resolve_a_standard_file_name
		Mismatched_mouse_name_in_the_paths
		Floating_point_number_query_condition
		PCA_Explained_not_found
		Unexpectedly_encountered_end_of_EventLog
		Missing_BlockTags
		Missing_Behavior
		Missing_TrialTags
		First_trial_too_short
		Last_trial_too_short
		Missing_EventLog
		BlockUID_not_found
		Block_lacks_BlockTag
		Blocks_table_missing_BlockTags_column
		Split_trials_less_than_existing_Trials
		Split_trials_more_than_existing_Trials
		Exception_occurs_in_BatchOirRegisterTiff
		ColumnsOfInterest_not_found
		Block_has_broken_trials
		Some_trials_are_incomplete
		OirPath_empty
		MergedCellRowRule_may_have_bugs_before_R2024b
		No_TagPeaks_found
	end
end