import { describe, bench, expect } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compress as npmCompress,
	decompress as npmDecompress,
} from "smol-string";

const options = { iterations: 10, timeout: 100000 };

describe.each(TestData)("Compression: $name", ({ name, input }) => {
	bench(
		"compress",
		() => {
			compress(input);
		},
		options
	);
	bench(
		"npm compress",
		() => {
			npmCompress(input);
		},
		options
	);
});

describe.each(TestData)("Decompression: $name", ({ name, input }) => {
	const compressed = compress(input);
	const npmCompressed = npmCompress(input);

	bench(
		"decompress",
		() => {
			const decompressed = decompress(compressed);
			expect(decompressed).toBe(input);
		},
		options
	);
	bench(
		"npm decompress",
		() => {
			const decompressed = npmDecompress(npmCompressed);
			expect(decompressed).toBe(input);
		},
		options
	);
});
