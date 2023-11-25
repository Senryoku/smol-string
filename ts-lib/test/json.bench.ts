import { describe, bench, expect, test, beforeAll } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compressPacked as npmCompress,
	decompressPacked as npmDecompress,
} from "smol-string/packed";

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
