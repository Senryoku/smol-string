export const json_512kb = import("../../test/data/512KB.json");
export const json_1mb = import("../../test/data/1MB.json");
export const rw_medium = import("../../test/data/rw_medium.json");
export const rw_large = import("../../test/data/rw_large.json");

export const TestData = [
	//{
	//	name: "Simple String",
	//	input: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
	//},
	{ name: "json_512kb", input: JSON.stringify(await json_512kb) },
	{ name: "json_1mb", input: JSON.stringify(await json_1mb) },
	{ name: "rw_medium", input: JSON.stringify(await rw_medium) },
	{ name: "rw_large", input: JSON.stringify(await rw_large) },
];
