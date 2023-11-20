import { describe, bench, expect, test, beforeAll } from "vitest";

import { TestData } from "./common.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compressPacked,
	decompressPacked,
} from "../dist/smol-string-packed.js";

import {
	compress as npmCompress,
	decompress as npmDecompress,
} from "smol-string";
import {
	compressPacked as npmCompressPacked,
	decompressPacked as npmDecompressPacked,
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

describe.each(TestData)("Compression (Packed): $name", ({ name, input }) => {
	bench(
		"compressPacked",
		() => {
			compressPacked(input);
		},
		options
	);
	bench(
		"npm compressPacked",
		() => {
			npmCompressPacked(input);
		},
		options
	);
});

describe.each(TestData)("Decompression: $name", ({ name, input }) => {
	const compressed = compress(input);

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
			const decompressed = npmDecompress(compressed);
			expect(decompressed).toBe(input);
		},
		options
	);
});

describe.each(TestData)("Decompression (Packed): $name", ({ name, input }) => {
	const compressedPacked = compressPacked(input);

	bench(
		"decompressPacked",
		() => {
			const decompressed = decompressPacked(compressedPacked);
			expect(decompressed).toBe(input);
		},
		options
	);
	bench(
		"npm decompressPacked",
		() => {
			const decompressed = npmDecompressPacked(compressedPacked);
			expect(decompressed).toBe(input);
		},
		options
	);
});
