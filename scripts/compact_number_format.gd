class_name CompactNumberFormat
extends RefCounted

const SUFFIXES := ["K", "M", "B", "T"]


static func format(value: int) -> String:
	if value == 0:
		return "0"

	var sign := ""
	var amount := value
	if amount < 0:
		sign = "-"
		amount = -amount

	if amount < 1000:
		return sign + str(amount)

	var suffix_index := -1
	var scaled := float(amount)
	var next_tier := scaled / 1000.0
	while next_tier >= 1.0 and suffix_index < SUFFIXES.size() - 1:
		scaled = next_tier
		suffix_index += 1
		next_tier = scaled / 1000.0

	var suffix: String = SUFFIXES[suffix_index]
	if scaled < 10.0:
		var truncated: float = floor(scaled * 10.0) / 10.0
		if is_equal_approx(truncated, floor(truncated)):
			return sign + str(int(truncated)) + suffix
		return sign + "%0.1f" % truncated + suffix

	return sign + str(int(floor(scaled))) + suffix
