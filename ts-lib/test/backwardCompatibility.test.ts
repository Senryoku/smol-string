import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";
import { RandomTestData } from "./randomTestData.js";

import { compress, decompress } from "../dist/smol-string.js";

import {
	compress as npmCompress,
	decompress as npmDecompress,
} from "../node_modules/smol-string/dist/smol-string.js";

describe("compress using previous version and decompress using latest version", () => {
	for (const arr of [TestData, RandomTestData]) {
		for (const { name, input } of arr) {
			test(name, async () => {
				const compressed = npmCompress(input);
				const decompressed = decompress(compressed);
				expect(decompressed).toBe(input);
			});
		}
	}
});

describe("compress using latest version and decompress using previous version", () => {
	for (const arr of [TestData, RandomTestData]) {
		for (const { name, input } of arr) {
			test(name, async () => {
				const compressed = compress(input);
				const decompressed = npmDecompress(compressed);
				expect(decompressed).toBe(input);
			});
		}
	}
});
