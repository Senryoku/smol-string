import { describe, expect, test } from "vitest";

import { TestData } from "./common.js";
import { RandomTestData } from "./randomTestData.js";

import { compress, decompress } from "../dist/smol-string.js";

describe("compress and decompress", () => {
	for (const arr of [TestData, RandomTestData]) {
		for (const { name, input } of arr) {
			test(name, async () => {
				const compressed = compress(input);
				const decompressed = decompress(compressed);
				expect(decompressed).toBe(input);
			});
		}
	}
});
