# GdUnit generated TestSuite
extends GdUnitTestSuite

const CompactNumberFormat = preload("res://scripts/compact_number_format.gd")


func test_format_small_values_without_suffix() -> void:
	assert_str(CompactNumberFormat.format(0)).is_equal("0")
	assert_str(CompactNumberFormat.format(1)).is_equal("1")
	assert_str(CompactNumberFormat.format(13)).is_equal("13")
	assert_str(CompactNumberFormat.format(101)).is_equal("101")
	assert_str(CompactNumberFormat.format(999)).is_equal("999")


func test_format_thousands_with_one_decimal_under_ten() -> void:
	assert_str(CompactNumberFormat.format(1000)).is_equal("1K")
	assert_str(CompactNumberFormat.format(1100)).is_equal("1.1K")
	assert_str(CompactNumberFormat.format(9900)).is_equal("9.9K")
	assert_str(CompactNumberFormat.format(9999)).is_equal("9.9K")


func test_format_thousands_without_decimal_at_ten_or_more() -> void:
	assert_str(CompactNumberFormat.format(10000)).is_equal("10K")
	assert_str(CompactNumberFormat.format(14000)).is_equal("14K")
	assert_str(CompactNumberFormat.format(95000)).is_equal("95K")
	assert_str(CompactNumberFormat.format(485000)).is_equal("485K")
	assert_str(CompactNumberFormat.format(999999)).is_equal("999K")


func test_format_millions_and_beyond() -> void:
	assert_str(CompactNumberFormat.format(1_000_000)).is_equal("1M")
	assert_str(CompactNumberFormat.format(3_500_000)).is_equal("3.5M")
	assert_str(CompactNumberFormat.format(9_950_000)).is_equal("9.9M")
	assert_str(CompactNumberFormat.format(10_000_000)).is_equal("10M")
	assert_str(CompactNumberFormat.format(1_000_000_000)).is_equal("1B")


func test_format_negative_values() -> void:
	assert_str(CompactNumberFormat.format(-13)).is_equal("-13")
	assert_str(CompactNumberFormat.format(-1100)).is_equal("-1.1K")
	assert_str(CompactNumberFormat.format(-14000)).is_equal("-14K")
